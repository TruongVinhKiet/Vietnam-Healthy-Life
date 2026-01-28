import hashlib
import json
import sqlite3
import time
from pathlib import Path
from typing import Optional, Dict

class ImageAnalysisCache:
    """
    Cache manager cho AI image analysis results
    - Sử dụng SHA256 hash của image bytes làm key
    - Lưu vào SQLite database
    - TTL: 30 days (có thể customize)
    """
    
    def __init__(self, db_path: str = "ai_analysis_cache.db", ttl_days: int = 30):
        self.db_path = db_path
        self.ttl_seconds = ttl_days * 24 * 3600
        self._init_db()
        
    def _init_db(self):
        """Khởi tạo database và table"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS analysis_cache (
                image_hash TEXT PRIMARY KEY,
                analysis_result TEXT NOT NULL,
                created_at INTEGER NOT NULL,
                accessed_at INTEGER NOT NULL,
                access_count INTEGER DEFAULT 1
            )
        """)
        
        # Index for cleanup
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_created_at 
            ON analysis_cache(created_at)
        """)
        
        conn.commit()
        conn.close()
        
        print(f"✅ Cache database initialized at {self.db_path}")
    
    def _compute_hash(self, image_bytes: bytes) -> str:
        """Tính SHA256 hash của image"""
        return hashlib.sha256(image_bytes).hexdigest()
    
    def get(self, image_bytes: bytes) -> Optional[Dict]:
        """
        Lấy cached result nếu có
        
        Returns:
            Dict với analysis result hoặc None nếu cache miss
        """
        image_hash = self._compute_hash(image_bytes)
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT analysis_result, created_at, access_count
            FROM analysis_cache
            WHERE image_hash = ?
        """, (image_hash,))
        
        row = cursor.fetchone()
        
        if row is None:
            conn.close()
            print(f"❌ Cache MISS for hash: {image_hash[:16]}...")
            return None
        
        analysis_json, created_at, access_count = row
        current_time = int(time.time())
        
        # Check TTL
        if current_time - created_at > self.ttl_seconds:
            # Expired - delete and return None
            cursor.execute("DELETE FROM analysis_cache WHERE image_hash = ?", (image_hash,))
            conn.commit()
            conn.close()
            print(f"⏰ Cache EXPIRED for hash: {image_hash[:16]}...")
            return None
        
        # Update access stats
        cursor.execute("""
            UPDATE analysis_cache
            SET accessed_at = ?, access_count = ?
            WHERE image_hash = ?
        """, (current_time, access_count + 1, image_hash))
        
        conn.commit()
        conn.close()
        
        print(f"✅ Cache HIT for hash: {image_hash[:16]}... (accessed {access_count + 1} times)")
        
        return json.loads(analysis_json)
    
    def set(self, image_bytes: bytes, analysis_result: Dict):
        """
        Lưu analysis result vào cache
        
        Args:
            image_bytes: Raw image bytes
            analysis_result: Dict result từ AI analysis
        """
        image_hash = self._compute_hash(image_bytes)
        analysis_json = json.dumps(analysis_result, ensure_ascii=False)
        current_time = int(time.time())
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT OR REPLACE INTO analysis_cache 
            (image_hash, analysis_result, created_at, accessed_at, access_count)
            VALUES (?, ?, ?, ?, 1)
        """, (image_hash, analysis_json, current_time, current_time))
        
        conn.commit()
        conn.close()
        
        print(f"💾 Cached result for hash: {image_hash[:16]}...")
    
    def cleanup_old_entries(self, days_to_keep: int = 30):
        """
        Xóa các entries cũ hơn X days
        
        Args:
            days_to_keep: Số ngày giữ lại
        """
        cutoff_time = int(time.time()) - (days_to_keep * 24 * 3600)
        
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            DELETE FROM analysis_cache
            WHERE created_at < ?
        """, (cutoff_time,))
        
        deleted_count = cursor.rowcount
        conn.commit()
        conn.close()
        
        print(f"🗑️ Cleaned up {deleted_count} old cache entries")
        return deleted_count
    
    def get_stats(self) -> Dict:
        """Lấy thống kê cache"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("SELECT COUNT(*) FROM analysis_cache")
        total_entries = cursor.fetchone()[0]
        
        cursor.execute("SELECT SUM(access_count) FROM analysis_cache")
        total_hits = cursor.fetchone()[0] or 0
        
        cursor.execute("SELECT AVG(access_count) FROM analysis_cache")
        avg_hits = cursor.fetchone()[0] or 0
        
        conn.close()
        
        return {
            "total_entries": total_entries,
            "total_cache_hits": total_hits,
            "average_hits_per_entry": round(avg_hits, 2)
        }
    
    def clear_all(self):
        """Xóa toàn bộ cache (dùng cho testing)"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        cursor.execute("DELETE FROM analysis_cache")
        conn.commit()
        conn.close()
        print("🗑️ All cache cleared")


# Singleton instance
_cache_instance = None

def get_cache_instance(db_path: str = "ai_analysis_cache.db", ttl_days: int = 30) -> ImageAnalysisCache:
    """Get or create cache singleton"""
    global _cache_instance
    if _cache_instance is None:
        _cache_instance = ImageAnalysisCache(db_path, ttl_days)
    return _cache_instance

"""
Translation helper module for Vietnamese translation
Uses googletrans library if available, falls back to simple mapping
"""

import re

try:
    from googletrans import Translator
    HAS_GOOGLETRANS = True
except ImportError:
    HAS_GOOGLETRANS = False
    print("[WARNING] googletrans not installed. Using simple translation mapping.")
    print("  Install with: pip install googletrans==4.0.0rc1")

# Simple translation mapping for common terms (fallback)
SIMPLE_TRANSLATIONS = {
    # Common food terms
    'milk': 'sữa',
    'cheese': 'phô mai',
    'yogurt': 'sữa chua',
    'beef': 'thịt bò',
    'chicken': 'thịt gà',
    'fish': 'cá',
    'egg': 'trứng',
    'bread': 'bánh mì',
    'rice': 'cơm',
    'water': 'nước',
    
    # Medical terms
    'drug': 'thuốc',
    'medication': 'thuốc',
    'disease': 'bệnh',
    'condition': 'tình trạng',
    'treatment': 'điều trị',
    'symptom': 'triệu chứng',
    'diagnosis': 'chẩn đoán',
    
    # Nutrients
    'protein': 'protein',
    'carbohydrate': 'carbohydrate',
    'fat': 'chất béo',
    'fiber': 'chất xơ',
    'vitamin': 'vitamin',
    'mineral': 'khoáng chất',
    'calcium': 'canxi',
    'iron': 'sắt',
    'magnesium': 'magie',
    'potassium': 'kali',
    'sodium': 'natri',
    'zinc': 'kẽm',
}

_translator = None

def get_translator():
    """Get translator instance (singleton)"""
    global _translator
    if _translator is None and HAS_GOOGLETRANS:
        try:
            _translator = Translator()
        except Exception as e:
            print(f"[WARNING] Failed to initialize translator: {e}")
            return None
    return _translator

def translate_to_vietnamese(text, use_api=True):
    """
    Translate English text to Vietnamese.
    
    Args:
        text: English text to translate
        use_api: Whether to use Google Translate API (if available)
    
    Returns:
        Vietnamese translation or original text if translation fails
    """
    # Handle None, NaN, float, and other non-string types
    if text is None:
        return ""
    
    # Check for NaN (float NaN)
    if isinstance(text, float):
        try:
            import math
            if math.isnan(text):
                return ""
        except:
            if text != text:  # NaN check without math module
                return ""
        text = str(text)
    
    if not isinstance(text, str):
        text = str(text) if text else ""
    
    if not text or not text.strip():
        return ""
    
    # Try Google Translate if available and requested
    if use_api and HAS_GOOGLETRANS:
        translator = get_translator()
        if translator:
            try:
                # Google Translate has rate limits, add small delay
                import time
                time.sleep(0.1)  # Small delay to avoid rate limiting
                
                result = translator.translate(text, src='en', dest='vi')
                if result and result.text:
                    return result.text
            except Exception as e:
                # If API fails, fall back to simple translation
                pass
    
    # Fall back to simple pattern-based translation
    translated = text
    text_lower = text.lower()
    
    # Replace known terms (longest first to avoid partial matches)
    for en_term, vi_term in sorted(SIMPLE_TRANSLATIONS.items(), key=lambda x: -len(x[0])):
        pattern = re.compile(re.escape(en_term), flags=re.IGNORECASE)
        if pattern.search(text_lower):
            translated = pattern.sub(vi_term, translated)
            text_lower = translated.lower()
    
    # If no translation occurred, return original (or a placeholder)
    if translated == text and len(text) > 0:
        # For short text that didn't match, return as-is
        # For longer text, indicate it needs manual translation
        if len(text) < 50:
            return text  # Keep original for short terms
        else:
            return f"[Cần dịch] {text}"  # Mark for manual translation
    
    return translated

def batch_translate(texts, use_api=True, batch_size=10):
    """
    Translate multiple texts efficiently.
    
    Args:
        texts: List of English texts
        use_api: Whether to use API
        batch_size: Number of texts to process in each batch
    
    Returns:
        List of Vietnamese translations
    """
    results = []
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        batch_results = [translate_to_vietnamese(t, use_api=use_api) for t in batch]
        results.extend(batch_results)
    
    return results

# Cache for translations to avoid repeated API calls
_translation_cache = {}

def translate_cached(text, use_api=True):
    """Translate with caching to avoid duplicate API calls"""
    # Handle None, NaN, float, and other non-string types
    if text is None:
        return ""
    
    # Check for NaN (float NaN)
    if isinstance(text, float):
        try:
            import math
            if math.isnan(text):
                return ""
        except:
            if text != text:  # NaN check without math module
                return ""
        text = str(text)
    
    if not isinstance(text, str):
        text = str(text) if text else ""
    
    if not text or not text.strip():
        return ""
    
    text_key = text.lower().strip()
    if text_key in _translation_cache:
        return _translation_cache[text_key]
    
    translated = translate_to_vietnamese(text, use_api=use_api)
    _translation_cache[text_key] = translated
    return translated


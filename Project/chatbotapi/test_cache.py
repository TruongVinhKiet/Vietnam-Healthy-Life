"""
Test script để demo cache system
"""
import requests
import time

API_URL = "http://localhost:8000"

def test_cache_stats():
    """Xem stats cache"""
    print("\n📊 CACHE STATS:")
    print("=" * 50)
    response = requests.get(f"{API_URL}/cache-stats")
    stats = response.json()
    
    print(f"Total entries: {stats['total_entries']}")
    print(f"Total cache hits: {stats['total_cache_hits']}")
    print(f"Average hits/entry: {stats['average_hits_per_entry']}")
    print(f"API calls SAVED: {stats['estimated_api_calls_saved']} 🚀")
    print("=" * 50)

def test_analyze_image(image_path: str, run_number: int):
    """Test phân tích ảnh"""
    print(f"\n🔍 RUN #{run_number}: Analyzing {image_path}...")
    
    with open(image_path, 'rb') as f:
        start_time = time.time()
        
        response = requests.post(
            f"{API_URL}/analyze-image",
            files={"file": f}
        )
        
        elapsed = time.time() - start_time
        
        if response.status_code == 200:
            result = response.json()
            print(f"✅ Success in {elapsed:.2f}s")
            
            if "items" in result and len(result["items"]) > 0:
                item = result["items"][0]
                print(f"   Item: {item.get('item_name', 'Unknown')}")
                print(f"   Calories: {item.get('nutrients', {}).get('enerc_kcal', 0)} kcal")
        else:
            print(f"❌ Error {response.status_code}: {response.text[:200]}")
        
        return elapsed

if __name__ == "__main__":
    print("🧪 TESTING AI IMAGE ANALYSIS CACHE SYSTEM")
    print("=" * 50)
    
    # Test image path - update this to your test image
    test_image = "D:\\App\\new\\test_food.jpg"
    
    print("\n⚠️  NOTE: Cần có file ảnh test tại:", test_image)
    print("    Nếu không có, tạo file ảnh bất kỳ hoặc update path\n")
    
    # Initial stats
    test_cache_stats()
    
    # Test 1: First call (cache MISS - will call API)
    print("\n" + "=" * 50)
    print("TEST 1: First analysis (Cache MISS)")
    print("Expected: Slow (~5-10s) - API call")
    print("=" * 50)
    try:
        time1 = test_analyze_image(test_image, 1)
    except Exception as e:
        print(f"❌ Error: {e}")
        print("\n💡 Tip: Đảm bảo có file ảnh test hoặc chờ API quota reset!")
        exit(1)
    
    # Test 2: Second call (cache HIT - instant)
    print("\n" + "=" * 50)
    print("TEST 2: Same image again (Cache HIT)")
    print("Expected: INSTANT (<0.1s) - from cache")
    print("=" * 50)
    time.sleep(1)
    time2 = test_analyze_image(test_image, 2)
    
    # Test 3: Third call (cache HIT again)
    print("\n" + "=" * 50)
    print("TEST 3: Third time (Cache HIT)")
    print("Expected: INSTANT (<0.1s) - from cache")
    print("=" * 50)
    time.sleep(1)
    time3 = test_analyze_image(test_image, 3)
    
    # Final stats
    test_cache_stats()
    
    # Summary
    print("\n" + "=" * 50)
    print("📈 PERFORMANCE SUMMARY:")
    print("=" * 50)
    print(f"Run 1 (API call):  {time1:.2f}s")
    print(f"Run 2 (Cache hit): {time2:.2f}s - {((time1-time2)/time1*100):.0f}% faster! 🚀")
    print(f"Run 3 (Cache hit): {time3:.2f}s - {((time1-time3)/time1*100):.0f}% faster! 🚀")
    
    if time2 < 0.5 and time3 < 0.5:
        print("\n✅ CACHE WORKING PERFECTLY!")
        print("💡 Estimated API cost saved: 66% (2 out of 3 calls)")
    else:
        print("\n⚠️  Cache might not be working. Check logs.")

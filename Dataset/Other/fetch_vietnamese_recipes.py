"""
Script để lấy dữ liệu công thức món ăn và thức uống Việt Nam từ các nguồn uy tín
và mapping vào CSDL hiện tại.

Nguồn dữ liệu:
1. Web scraping từ các trang uy tín (vov.vn/food, monngonviet.com.vn, cookpad.vn)
2. Dataset có sẵn (nếu có)
3. Manual data entry support

Output: CSV/SQL files để import vào database
"""

import os
import re
import json
import time
import csv
import requests
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse
import psycopg2
from psycopg2.extras import execute_values

try:
    import pandas as pd
except ImportError:
    pd = None

# =====================================================================
# CONFIG
# =====================================================================
SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = SCRIPT_DIR / "vietnamese_recipes_output"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Database connection (optional - can export to CSV instead)
DB_CONFIG = {
    "host": os.environ.get("DB_HOST", "localhost"),
    "port": os.environ.get("DB_PORT", "5432"),
    "database": os.environ.get("DB_NAME", "nutrition_db"),
    "user": os.environ.get("DB_USER", "postgres"),
    "password": os.environ.get("DB_PASSWORD", ""),
}

# Sources for Vietnamese recipes
RECIPE_SOURCES = {
    "cooky": {
        "base_url": "https://www.cooky.vn",
        "listing_url": "https://www.cooky.vn/cong-thuc",
        "enabled": True,
    },
    "amthuc365": {
        "base_url": "https://amthuc365.vn",
        "listing_url": "https://amthuc365.vn/cong-thuc",
        "enabled": True,
    },
    "bepgiadinh": {
        "base_url": "https://bepgiadinh.vn",
        "listing_url": "https://bepgiadinh.vn/cong-thuc",
        "enabled": True,
    },
    "ngon": {
        "base_url": "https://ngon.vn",
        "listing_url": "https://ngon.vn/cong-thuc",
        "enabled": True,
    },
    "vov": {
        "base_url": "https://vov.vn/doi-song/am-thuc",
        "listing_url": "https://vov.vn/doi-song/am-thuc",
        "enabled": True,
    },
    "monngonviet": {
        "base_url": "https://www.monngonviet.com.vn",
        "listing_url": "https://www.monngonviet.com.vn/mon-ngon",
        "enabled": True,
    },
}

# Request settings
REQUEST_TIMEOUT = 15
REQUEST_DELAY = 1.5  # seconds between requests
MAX_RECIPES_PER_SOURCE = 500
MAX_RETRIES = 3  # Number of retries for failed requests

# User-Agent để tránh bị block
HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7",
    "Accept-Encoding": "gzip, deflate, br",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
}

# =====================================================================
# UTILITIES
# =====================================================================
def normalize_text(text: str) -> str:
    """Normalize Vietnamese text"""
    if not text:
        return ""
    # Remove extra whitespace
    text = re.sub(r"\s+", " ", str(text)).strip()
    return text

def make_request(url: str, max_retries: int = MAX_RETRIES) -> Optional[requests.Response]:
    """Make HTTP request with retry logic"""
    for attempt in range(max_retries):
        try:
            response = requests.get(url, headers=HEADERS, timeout=REQUEST_TIMEOUT, allow_redirects=True)
            response.raise_for_status()
            return response
        except requests.exceptions.RequestException as e:
            if attempt < max_retries - 1:
                wait_time = (attempt + 1) * 2  # Exponential backoff
                print(f"    [RETRY] Attempt {attempt + 1}/{max_retries} failed for {url[:80]}...")
                time.sleep(wait_time)
            else:
                return None
    return None

def clean_url(url: str) -> str:
    """Clean URL by removing query parameters and fragments"""
    parsed = urlparse(url)
    return f"{parsed.scheme}://{parsed.netloc}{parsed.path}"

def is_valid_recipe_url(url: str) -> bool:
    """Check if URL is a valid recipe URL"""
    if not url or len(url) < 10:
        return False
    # Must contain recipe-related keywords
    recipe_keywords = ['cong-thuc', 'recipe', 'mon-ngon', 'am-thuc', 'huong-dan']
    url_lower = url.lower()
    return any(keyword in url_lower for keyword in recipe_keywords)

def sql_escape(text: str) -> str:
    """Escape SQL string"""
    if not text or text is None:
        return "NULL"
    return "'" + str(text).replace("'", "''") + "'"

def parse_weight(text: str) -> Optional[float]:
    """Parse weight from text like '200g', '1kg', '500 gram'"""
    if not text:
        return None
    
    text = text.lower().strip()
    # Remove common words
    text = re.sub(r"(khoảng|tầm|chừng|đến|từ)\s*", "", text)
    
    # Extract number
    match = re.search(r"(\d+\.?\d*)", text)
    if not match:
        return None
    
    value = float(match.group(1))
    
    # Convert to grams
    if "kg" in text or "kilogram" in text:
        value *= 1000
    elif "l" in text and "ml" not in text:
        value *= 1000  # Assume liquid in ml
    elif "ml" in text:
        # For liquids, approximate: 1ml ≈ 1g for water-based
        pass
    
    return round(value, 2)

def get_food_id_from_name(food_name: str, food_name_map: Dict[str, int]) -> Optional[int]:
    """Try to find food_id from food name using fuzzy matching"""
    food_name_lower = food_name.lower().strip()
    
    # Exact match
    if food_name_lower in food_name_map:
        return food_name_map[food_name_lower]
    
    # Partial match
    for name, food_id in food_name_map.items():
        if food_name_lower in name or name in food_name_lower:
            return food_id
    
    return None

# =====================================================================
# WEB SCRAPING - Cooky.vn (Most popular Vietnamese recipe site)
# =====================================================================
def scrape_cooky_recipes(max_recipes: int = 100) -> List[Dict]:
    """Scrape recipes from Cooky.vn"""
    recipes = []
    
    try:
        base_url = RECIPE_SOURCES['cooky']['base_url']
        listing_url = RECIPE_SOURCES['cooky']['listing_url']
        
        for page in range(1, 21):  # Try up to 20 pages
            if len(recipes) >= max_recipes:
                break
            
            url = f"{listing_url}?page={page}" if page > 1 else listing_url
            print(f"  Fetching Cooky.vn page {page}...")
            
            try:
                response = make_request(url)
                if not response:
                    print(f"    [WARNING] Failed to fetch page {page}, skipping...")
                    continue
                
                soup = BeautifulSoup(response.content, 'html.parser')
                
                # Find recipe links - Cooky.vn uses various patterns
                recipe_links = []
                # Try multiple selectors
                for selector in [
                    'a[href*="/cong-thuc/"]',
                    'a[href*="/recipe/"]',
                    '.recipe-item a',
                    '.recipe-title a',
                    'h3 a',
                    'h2 a',
                ]:
                    links = soup.select(selector)
                    recipe_links.extend([link.get('href', '') for link in links if link.get('href')])
                
                # Remove duplicates and filter
                seen_urls = set()
                for link in recipe_links:
                    if len(recipes) >= max_recipes:
                        break
                    
                    if not link:
                        continue
                    
                    recipe_url = urljoin(base_url, link)
                    cleaned_url = clean_url(recipe_url)
                    
                    # Skip if not valid recipe URL or already seen
                    if not is_valid_recipe_url(recipe_url) or cleaned_url in seen_urls:
                        continue
                    
                    seen_urls.add(cleaned_url)
                    
                    recipe = scrape_cooky_recipe_detail(recipe_url)
                    if recipe:
                        recipes.append(recipe)
                        print(f"    [OK] {recipe.get('vietnamese_name', 'Unknown')}")
                    else:
                        print(f"    [SKIP] Failed to extract recipe from {recipe_url[:80]}")
                    
                    time.sleep(REQUEST_DELAY)
                
                if not recipe_links:
                    print(f"    [WARNING] No recipe links found on page {page}")
                    break
                    
            except Exception as e:
                print(f"    [ERROR] Failed to fetch page {page}: {e}")
                continue
        
    except Exception as e:
        print(f"[ERROR] Cooky.vn scraping failed: {e}")
    
    return recipes

def scrape_cooky_recipe_detail(url: str) -> Optional[Dict]:
    """Scrape individual recipe from Cooky.vn"""
    try:
        response = make_request(url)
        if not response:
            return None
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract title
        title = ""
        for selector in ['h1', '.recipe-title', '.title', 'h2.recipe-name']:
            elem = soup.select_one(selector)
            if elem:
                title = normalize_text(elem.get_text())
                break
        
        if not title:
            return None
        
        # Extract ingredients
        ingredients = []
        # Look for ingredient sections
        for section in soup.find_all(['div', 'section', 'ul', 'ol']):
            section_text = section.get_text().lower()
            if any(kw in section_text for kw in ['nguyên liệu', 'ingredient', 'chuẩn bị', 'vật liệu']):
                # Find list items
                for li in section.find_all(['li', 'div']):
                    text = normalize_text(li.get_text())
                    if text and len(text) > 3 and len(text) < 200:
                        # Check if it looks like an ingredient
                        if any(char in text for char in ['g', 'kg', 'ml', 'l', 'củ', 'quả', 'lá', 'nhánh', 'muỗng', 'thìa']):
                            ingredients.append(text)
        
        # Extract instructions
        instructions = []
        for section in soup.find_all(['div', 'section', 'ol', 'ul']):
            section_text = section.get_text().lower()
            if any(kw in section_text for kw in ['cách làm', 'thực hiện', 'hướng dẫn', 'bước', 'instruction']):
                # Find numbered steps
                for step in section.find_all(['li', 'p', 'div']):
                    text = normalize_text(step.get_text())
                    # Remove step numbers
                    text = re.sub(r'^\d+[\.\)]\s*', '', text)
                    if text and len(text) > 20:
                        instructions.append(text)
        
        # Extract description
        description = ""
        for meta in soup.find_all('meta'):
            if meta.get('property') == 'og:description' or meta.get('name') == 'description':
                description = normalize_text(meta.get('content', ''))
                break
        
        # Extract image
        image_url = ""
        for img in soup.find_all('img'):
            src = img.get('src', '') or img.get('data-src', '')
            if src and any(ext in src.lower() for ext in ['.jpg', '.jpeg', '.png', '.webp']):
                image_url = urljoin(url, src)
                break
        
        # Determine category
        category = "main"
        title_lower = title.lower()
        if any(kw in title_lower for kw in ['canh', 'súp', 'cháo']):
            category = "soup"
        elif any(kw in title_lower for kw in ['gỏi', 'nộm', 'salad']):
            category = "salad"
        elif any(kw in title_lower for kw in ['chè', 'bánh', 'kem', 'dessert']):
            category = "dessert"
        elif any(kw in title_lower for kw in ['nước', 'sinh tố', 'trà', 'cà phê', 'drink', 'beverage']):
            category = "drink"
        elif any(kw in title_lower for kw in ['khai vị', 'appetizer']):
            category = "appetizer"
        
        return {
            "name": title,
            "vietnamese_name": title,
            "description": description,
            "category": category,
            "ingredients": ingredients[:20],  # Limit to 20 ingredients
            "instructions": "\n".join(instructions[:15]),  # Limit to 15 steps
            "image_url": image_url,
            "source_url": url,
            "source": "cooky",
            "serving_size_g": 200,
        }
        
    except Exception as e:
        print(f"    [ERROR] Failed to scrape {url}: {e}")
        return None

# =====================================================================
# WEB SCRAPING - AmThuc365.vn
# =====================================================================
def scrape_amthuc365_recipes(max_recipes: int = 100) -> List[Dict]:
    """Scrape recipes from AmThuc365.vn"""
    recipes = []
    
    try:
        base_url = RECIPE_SOURCES['amthuc365']['base_url']
        listing_url = RECIPE_SOURCES['amthuc365']['listing_url']
        
        for page in range(1, 16):
            if len(recipes) >= max_recipes:
                break
            
            url = f"{listing_url}?page={page}" if page > 1 else listing_url
            print(f"  Fetching AmThuc365.vn page {page}...")
            
            try:
                response = make_request(url)
                if not response:
                    print(f"    [WARNING] Failed to fetch page {page}, skipping...")
                    continue
                
                soup = BeautifulSoup(response.content, 'html.parser')
                
                # Find recipe links
                recipe_links = []
                for link in soup.find_all('a', href=True):
                    href = link.get('href', '')
                    if '/cong-thuc/' in href or '/recipe/' in href:
                        recipe_links.append(href)
                
                seen_urls = set()
                for link in recipe_links[:15]:
                    if len(recipes) >= max_recipes:
                        break
                    
                    recipe_url = urljoin(base_url, link)
                    cleaned_url = clean_url(recipe_url)
                    
                    if not is_valid_recipe_url(recipe_url) or cleaned_url in seen_urls:
                        continue
                    
                    seen_urls.add(cleaned_url)
                    
                    recipe = scrape_amthuc365_recipe_detail(recipe_url)
                    if recipe:
                        recipes.append(recipe)
                        print(f"    [OK] {recipe.get('vietnamese_name', 'Unknown')}")
                    else:
                        print(f"    [SKIP] Failed to extract recipe")
                    
                    time.sleep(REQUEST_DELAY)
                
            except Exception as e:
                print(f"    [ERROR] Failed to fetch page {page}: {e}")
                continue
        
    except Exception as e:
        print(f"[ERROR] AmThuc365.vn scraping failed: {e}")
    
    return recipes

def scrape_amthuc365_recipe_detail(url: str) -> Optional[Dict]:
    """Scrape individual recipe from AmThuc365.vn"""
    try:
        response = make_request(url)
        if not response:
            return None
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract title
        title_elem = soup.find('h1') or soup.find('h2') or soup.find('title')
        title = normalize_text(title_elem.get_text()) if title_elem else ""
        
        if not title:
            return None
        
        # Extract ingredients and instructions (similar to cooky)
        ingredients = []
        instructions = []
        
        # Find content area
        content = soup.find('article') or soup.find('div', class_=re.compile(r'content|recipe|post'))
        if content:
            for elem in content.find_all(['ul', 'ol', 'div']):
                text = elem.get_text().lower()
                if any(kw in text for kw in ['nguyên liệu', 'ingredient']):
                    for li in elem.find_all(['li', 'p']):
                        ing = normalize_text(li.get_text())
                        if ing and len(ing) > 3:
                            ingredients.append(ing)
                elif any(kw in text for kw in ['cách làm', 'thực hiện', 'hướng dẫn']):
                    for li in elem.find_all(['li', 'p']):
                        step = normalize_text(li.get_text())
                        step = re.sub(r'^\d+[\.\)]\s*', '', step)
                        if step and len(step) > 20:
                            instructions.append(step)
        
        # Extract image
        img = soup.find('img', src=re.compile(r'\.(jpg|jpeg|png)'))
        image_url = urljoin(url, img.get('src', '')) if img else ""
        
        # Category
        category = "main"
        if any(kw in title.lower() for kw in ['canh', 'súp']):
            category = "soup"
        elif any(kw in title.lower() for kw in ['nước', 'drink']):
            category = "drink"
        
        return {
            "name": title,
            "vietnamese_name": title,
            "description": "",
            "category": category,
            "ingredients": ingredients[:20],
            "instructions": "\n".join(instructions[:15]),
            "image_url": image_url,
            "source_url": url,
            "source": "amthuc365",
            "serving_size_g": 200,
        }
        
    except Exception as e:
        print(f"    [ERROR] Failed to scrape {url}: {e}")
        return None

# =====================================================================
# WEB SCRAPING - VOV.vn
# =====================================================================
def scrape_vov_recipes(max_recipes: int = 100) -> List[Dict]:
    """Scrape recipes from VOV.vn"""
    recipes = []
    
    try:
        # Get recipe listing pages
        for page in range(1, 11):  # Try first 10 pages
            if len(recipes) >= max_recipes:
                break
            
            url = f"{RECIPE_SOURCES['vov']['base_url']}?page={page}"
            print(f"  Fetching VOV page {page}...")
            
            try:
                response = make_request(url)
                if not response:
                    print(f"    [WARNING] Failed to fetch page {page}, skipping...")
                    continue
                
                soup = BeautifulSoup(response.content, 'html.parser')
                
                # Find recipe links (adjust selector based on actual HTML structure)
                article_links = soup.find_all('a', href=re.compile(r'/doi-song/am-thuc/'))
                
                for link in article_links[:20]:  # Limit per page
                    if len(recipes) >= max_recipes:
                        break
                    
                    recipe_url = urljoin(RECIPE_SOURCES['vov']['base_url'], link.get('href', ''))
                    if not recipe_url or recipe_url in [r.get('source_url') for r in recipes]:
                        continue
                    
                    recipe = scrape_vov_recipe_detail(recipe_url)
                    if recipe:
                        recipes.append(recipe)
                        print(f"    [OK] {recipe.get('vietnamese_name', 'Unknown')}")
                    
                    time.sleep(REQUEST_DELAY)
                    
            except Exception as e:
                print(f"    [ERROR] Failed to fetch page {page}: {e}")
                continue
        
    except Exception as e:
        print(f"[ERROR] VOV scraping failed: {e}")
    
    return recipes

def scrape_vov_recipe_detail(url: str) -> Optional[Dict]:
    """Scrape individual recipe from VOV.vn"""
    try:
        response = make_request(url)
        if not response:
            return None
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract recipe information (adjust selectors)
        title_elem = soup.find('h1') or soup.find('h2')
        title = normalize_text(title_elem.get_text()) if title_elem else ""
        
        if not title:
            return None
        
        # Try to find ingredients
        ingredients = []
        # Look for common ingredient list patterns
        for elem in soup.find_all(['ul', 'ol', 'div']):
            text = elem.get_text()
            if any(keyword in text.lower() for keyword in ['nguyên liệu', 'ingredient', 'chuẩn bị']):
                for li in elem.find_all('li'):
                    ing_text = normalize_text(li.get_text())
                    if ing_text:
                        ingredients.append(ing_text)
                break
        
        # Try to find instructions
        instructions = []
        for elem in soup.find_all(['div', 'article']):
            text = elem.get_text()
            if any(keyword in text.lower() for keyword in ['cách làm', 'thực hiện', 'instruction']):
                # Split by numbered steps or paragraphs
                steps = re.split(r'\n+|\d+\.', text)
                for step in steps:
                    step = normalize_text(step)
                    if len(step) > 20:
                        instructions.append(step)
                break
        
        # Try to find image
        img_elem = soup.find('img', src=re.compile(r'\.(jpg|jpeg|png)'))
        image_url = img_elem.get('src', '') if img_elem else ""
        
        # Determine category
        category = "món chính"  # default
        if any(kw in title.lower() for kw in ['canh', 'súp', 'cháo']):
            category = "soup"
        elif any(kw in title.lower() for kw in ['gỏi', 'salad', 'nộm']):
            category = "salad"
        elif any(kw in title.lower() for kw in ['tráng miệng', 'chè', 'bánh']):
            category = "dessert"
        elif any(kw in title.lower() for kw in ['nước', 'sinh tố', 'nước ép']):
            category = "drink"
        
        return {
            "name": title,
            "vietnamese_name": title,
            "description": normalize_text(soup.find('meta', property='og:description').get('content', '')) if soup.find('meta', property='og:description') else "",
            "category": category,
            "ingredients": ingredients,
            "instructions": "\n".join(instructions),
            "image_url": image_url,
            "source_url": url,
            "source": "vov",
            "serving_size_g": 200,  # Default estimate
        }
        
    except Exception as e:
        print(f"    [ERROR] Failed to scrape {url}: {e}")
        return None

# =====================================================================
# WEB SCRAPING - MonNgonViet.com.vn
# =====================================================================
def scrape_monngonviet_recipes(max_recipes: int = 100) -> List[Dict]:
    """Scrape recipes from MonNgonViet.com.vn"""
    recipes = []
    
    try:
        base_url = RECIPE_SOURCES['monngonviet']['base_url']
        
        # Try to find recipe listing
        for page in range(1, 11):
            if len(recipes) >= max_recipes:
                break
            
            url = f"{base_url}/mon-ngon?page={page}"
            print(f"  Fetching MonNgonViet page {page}...")
            
            try:
                response = make_request(url)
                if not response:
                    print(f"    [WARNING] Failed to fetch page {page}, skipping...")
                    continue
                
                soup = BeautifulSoup(response.content, 'html.parser')
                
                # Find recipe links
                recipe_links = soup.find_all('a', href=re.compile(r'/mon-ngon/'))
                
                for link in recipe_links[:20]:
                    if len(recipes) >= max_recipes:
                        break
                    
                    recipe_url = urljoin(base_url, link.get('href', ''))
                    if not recipe_url or recipe_url in [r.get('source_url') for r in recipes]:
                        continue
                    
                    recipe = scrape_monngonviet_recipe_detail(recipe_url)
                    if recipe:
                        recipes.append(recipe)
                        print(f"    [OK] {recipe.get('vietnamese_name', 'Unknown')}")
                    
                    time.sleep(REQUEST_DELAY)
                    
            except Exception as e:
                print(f"    [ERROR] Failed to fetch page {page}: {e}")
                continue
        
    except Exception as e:
        print(f"[ERROR] MonNgonViet scraping failed: {e}")
    
    return recipes

def scrape_monngonviet_recipe_detail(url: str) -> Optional[Dict]:
    """Scrape individual recipe from MonNgonViet.com.vn"""
    try:
        response = make_request(url)
        if not response:
            return None
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # Extract recipe (similar to VOV but adjust selectors)
        title_elem = soup.find('h1') or soup.find('title')
        title = normalize_text(title_elem.get_text()) if title_elem else ""
        
        if not title:
            return None
        
        # Find ingredients and instructions
        ingredients = []
        instructions = []
        
        # Common patterns for Vietnamese recipe sites
        content_area = soup.find('article') or soup.find('div', class_=re.compile(r'content|recipe'))
        if content_area:
            for p in content_area.find_all(['p', 'li', 'div']):
                text = normalize_text(p.get_text())
                if any(kw in text.lower() for kw in ['nguyên liệu', 'chuẩn bị']):
                    continue
                if len(text) > 5 and len(text) < 200:
                    if any(kw in text.lower() for kw in ['g', 'kg', 'ml', 'lít', 'củ', 'quả', 'lá', 'nhánh']):
                        ingredients.append(text)
                elif len(text) > 50:
                    instructions.append(text)
        
        # Find image
        img_elem = soup.find('img', src=re.compile(r'\.(jpg|jpeg|png)'))
        image_url = img_elem.get('src', '') if img_elem else ""
        
        # Determine category
        category = "món chính"
        title_lower = title.lower()
        if any(kw in title_lower for kw in ['canh', 'súp']):
            category = "soup"
        elif any(kw in title_lower for kw in ['gỏi', 'nộm']):
            category = "salad"
        elif any(kw in title_lower for kw in ['chè', 'bánh', 'kem']):
            category = "dessert"
        elif any(kw in title_lower for kw in ['nước', 'sinh tố', 'trà', 'cà phê']):
            category = "drink"
        
        return {
            "name": title,
            "vietnamese_name": title,
            "description": "",
            "category": category,
            "ingredients": ingredients,
            "instructions": "\n".join(instructions),
            "image_url": image_url,
            "source_url": url,
            "source": "monngonviet",
            "serving_size_g": 200,
        }
        
    except Exception as e:
        print(f"    [ERROR] Failed to scrape {url}: {e}")
        return None

# =====================================================================
# LOAD FROM SQL FILE (extended_tables_vietnam.sql)
# =====================================================================
def load_recipes_from_sql() -> List[Dict]:
    """Load recipes from extended_tables_vietnam.sql file"""
    sql_file = SCRIPT_DIR / "InsertIntoSQL" / "extended_tables_vietnam.sql"
    recipes = []
    
    if not sql_file.exists():
        print(f"[WARNING] SQL file not found at {sql_file}")
        return recipes
    
    try:
        with open(sql_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Parse dish INSERT statements - more flexible pattern
        dish_section = re.search(r"INSERT INTO dish.*?VALUES\s*(.*?)(?:ON CONFLICT|;)", content, re.DOTALL | re.IGNORECASE)
        
        if dish_section:
            dish_block = dish_section.group(1)
            # Find all dish records - handle multi-line
            dish_records = re.findall(r"\((\d+),\s*'([^']*(?:''[^']*)*)',\s*'([^']*(?:''[^']*)*)',\s*'([^']*(?:''[^']*)*)',\s*'([^']+)',\s*(\d+(?:\.\d+)?)", dish_block, re.IGNORECASE)
            
            for record in dish_records:
                try:
                    dish_id, name_en, name_vi, description, category, serving_size = record
                    recipes.append({
                        "dish_id": int(dish_id),
                        "name": name_en.replace("''", "'").strip(),
                        "vietnamese_name": name_vi.replace("''", "'").strip(),
                        "description": description.replace("''", "'").strip(),
                        "category": category.lower().strip(),
                        "serving_size_g": float(serving_size),
                        "source": "extended_sql",
                    })
                except Exception as e:
                    continue
        
        # Parse drink INSERT statements
        drink_section = re.search(r"INSERT INTO drink.*?VALUES\s*(.*?)(?:ON CONFLICT|;)", content, re.DOTALL | re.IGNORECASE)
        
        if drink_section:
            drink_block = drink_section.group(1)
            # Extract drink records - need to parse more carefully due to many fields
            # Pattern: (id, 'name', 'vi_name', 'desc', 'cat', 'base', volume, temp, hydration, caffeine, sugar_free, ...)
            drink_records = re.findall(r"\((\d+),\s*'([^']*(?:''[^']*)*)',\s*'([^']*(?:''[^']*)*)',\s*'([^']*(?:''[^']*)*)',\s*'([^']+)'", drink_block, re.IGNORECASE)
            
            for record in drink_records[:40]:  # Limit to 40 drinks
                try:
                    drink_id, name_en, name_vi, description, category = record
                    # Try to extract default_volume_ml from the same line
                    drink_line_match = re.search(rf"\({drink_id},[^)]+,\s*(\d+(?:\.\d+)?)", drink_block)
                    volume = float(drink_line_match.group(1)) if drink_line_match else 250
                    
                    recipes.append({
                        "drink_id": int(drink_id),
                        "name": name_en.replace("''", "'").strip(),
                        "vietnamese_name": name_vi.replace("''", "'").strip(),
                        "description": description.replace("''", "'").strip(),
                        "category": category.lower().strip(),
                        "serving_size_g": volume,
                        "source": "extended_sql",
                    })
                except Exception as e:
                    continue
        
        print(f"[OK] Loaded {len(recipes)} recipes from extended_tables_vietnam.sql")
        
    except Exception as e:
        print(f"[ERROR] Failed to load recipes from SQL file: {e}")
        import traceback
        traceback.print_exc()
    
    return recipes

# =====================================================================
# LOAD FROM EXISTING VIETNAMESE FOOD DATASET
# =====================================================================
def load_vietnamese_food_dataset() -> List[Dict]:
    """Load Vietnamese food data from existing dataset"""
    dataset_file = SCRIPT_DIR / "Vietnamese-Food-Nutrition-Analysis-main" / "data" / "data.csv"
    recipes = []
    
    if not dataset_file.exists():
        print(f"[WARNING] Vietnamese food dataset not found at {dataset_file}")
        return recipes
    
    try:
        if pd is None:
            # Fallback to manual CSV reading
            with open(dataset_file, 'r', encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    food_name = row.get('TÊN THỨC ĂN', '').strip()
                    if not food_name:
                        continue
                    
                    # Parse nutrition data
                    try:
                        calories = float(row.get('Calories (kcal)', '0').replace(',', '.'))
                        protein = float(row.get('Protein (g)', '0').replace(',', '.'))
                        fat = float(row.get('Fat (g)', '0').replace(',', '.'))
                        carbs = float(row.get('Carbonhydrates (g)', '0').replace(',', '.'))
                        fiber = float(row.get('Chất xơ (g)', '0').replace(',', '.'))
                        category = row.get('Loại', '')
                    except:
                        continue
                    
                    recipes.append({
                        "name": food_name,
                        "vietnamese_name": food_name,
                        "description": f"Vietnamese food: {food_name}",
                        "category": map_category(category),
                        "serving_size_g": 100,
                        "nutrition": {
                            "calories": calories,
                            "protein": protein,
                            "fat": fat,
                            "carbs": carbs,
                            "fiber": fiber,
                        },
                        "source": "vietnamese_food_dataset",
                    })
        else:
            df = pd.read_csv(dataset_file, encoding='utf-8')
            for _, row in df.iterrows():
                food_name = str(row.get('TÊN THỨC ĂN', '')).strip()
                if not food_name or food_name == 'nan':
                    continue
                
                try:
                    calories = float(str(row.get('Calories (kcal)', '0')).replace(',', '.'))
                    protein = float(str(row.get('Protein (g)', '0')).replace(',', '.'))
                    fat = float(str(row.get('Fat (g)', '0')).replace(',', '.'))
                    carbs = float(str(row.get('Carbonhydrates (g)', '0')).replace(',', '.'))
                    fiber = float(str(row.get('Chất xơ (g)', '0')).replace(',', '.'))
                    category = str(row.get('Loại', '')).strip()
                except:
                    continue
                
                recipes.append({
                    "name": food_name,
                    "vietnamese_name": food_name,
                    "description": f"Vietnamese food: {food_name}",
                    "category": map_category(category),
                    "serving_size_g": 100,
                    "nutrition": {
                        "calories": calories,
                        "protein": protein,
                        "fat": fat,
                        "carbs": carbs,
                        "fiber": fiber,
                    },
                    "source": "vietnamese_food_dataset",
                })
        
        print(f"[OK] Loaded {len(recipes)} foods from Vietnamese food dataset")
        
    except Exception as e:
        print(f"[ERROR] Failed to load Vietnamese food dataset: {e}")
    
    return recipes

def map_category(category: str) -> str:
    """Map Vietnamese food category to dish category"""
    if not category:
        return "main"
    
    category_lower = category.lower()
    
    category_map = {
        "ngũ cốc": "grain",
        "thịt": "meat",
        "cá": "fish",
        "rau": "vegetable",
        "quả": "fruit",
        "sữa": "dairy",
        "đồ uống": "drink",
        "bánh": "dessert",
        "canh": "soup",
        "gỏi": "salad",
        "nộm": "salad",
    }
    
    for key, mapped in category_map.items():
        if key in category_lower:
            return mapped
    
    return "main"

# =====================================================================
# MANUAL RECIPE DATA (Popular Vietnamese dishes with recipes)
# =====================================================================
MANUAL_RECIPES = [
    {
        "name": "Pho Bo",
        "vietnamese_name": "Phở Bò",
        "description": "Traditional Vietnamese beef noodle soup",
        "category": "soup",
        "serving_size_g": 400,
        "ingredients": [
            "500g bánh phở",
            "300g thịt bò",
            "1 củ hành tây",
            "2 củ gừng",
            "Quế, hoa hồi, thảo quả",
            "Hành lá, rau thơm",
            "Nước mắm, muối",
        ],
        "instructions": """
        1. Nấu nước dùng với xương bò, hành, gừng và các gia vị
        2. Luộc bánh phở trong nước sôi
        3. Thái thịt bò mỏng, chần qua nước dùng
        4. Xếp bánh phở vào bát, cho thịt bò, hành lá, rau thơm
        5. Rót nước dùng nóng vào, thêm nước mắm và tiêu
        """,
        "source": "manual",
    },
    {
        "name": "Banh Mi",
        "vietnamese_name": "Bánh Mì",
        "description": "Vietnamese sandwich",
        "category": "main",
        "serving_size_g": 150,
        "ingredients": [
            "1 ổ bánh mì",
            "50g thịt nguội",
            "50g pate",
            "Rau củ ngâm chua",
            "Rau mùi, ớt",
            "Nước sốt",
        ],
        "instructions": """
        1. Cắt đôi bánh mì
        2. Phết pate vào một bên
        3. Xếp thịt nguội, rau củ ngâm chua
        4. Thêm rau mùi, ớt và nước sốt
        """,
        "source": "manual",
    },
    {
        "name": "Ca Phe Sua Da",
        "vietnamese_name": "Cà Phê Sữa Đá",
        "description": "Vietnamese iced coffee with condensed milk",
        "category": "drink",
        "serving_size_g": 200,
        "ingredients": [
            "20g cà phê phin",
            "30ml sữa đặc",
            "Đá viên",
            "Nước sôi 100ml",
        ],
        "instructions": """
        1. Cho cà phê vào phin, đổ nước sôi
        2. Đợi cà phê nhỏ giọt
        3. Cho sữa đặc vào ly
        4. Đổ cà phê vào, khuấy đều
        5. Thêm đá viên
        """,
        "source": "manual",
    },
    {
        "name": "Goi Cuon",
        "vietnamese_name": "Gỏi Cuốn",
        "description": "Fresh Vietnamese spring rolls",
        "category": "appetizer",
        "serving_size_g": 100,
        "ingredients": [
            "8 bánh tráng",
            "200g tôm",
            "100g thịt ba chỉ",
            "Rau xà lách, rau thơm",
            "Bún tươi",
            "Nước mắm pha",
        ],
        "instructions": """
        1. Luộc tôm và thịt, thái mỏng
        2. Ngâm bánh tráng trong nước ấm
        3. Xếp rau, bún, tôm, thịt lên bánh tráng
        4. Cuốn lại chặt tay
        5. Chấm với nước mắm pha
        """,
        "source": "manual",
    },
    {
        "name": "Bun Cha",
        "vietnamese_name": "Bún Chả",
        "description": "Grilled pork with vermicelli noodles",
        "category": "main",
        "serving_size_g": 350,
        "ingredients": [
            "200g thịt ba chỉ",
            "200g bún tươi",
            "Rau sống, giá đỗ",
            "Nước mắm pha",
            "Tỏi, ớt",
        ],
        "instructions": """
        1. Ướp thịt với nước mắm, tỏi, đường
        2. Nướng thịt trên than hoa
        3. Pha nước mắm với tỏi, ớt, chanh
        4. Luộc bún, để ráo
        5. Xếp bún, rau, giá vào bát
        6. Cho thịt nướng, rưới nước mắm
        """,
        "source": "manual",
    },
    {
        "name": "Pho Ga",
        "vietnamese_name": "Phở Gà",
        "description": "Vietnamese chicken noodle soup",
        "category": "soup",
        "serving_size_g": 400,
        "ingredients": [
            "500g bánh phở",
            "300g thịt gà",
            "1 con gà ta",
            "Hành tây, gừng",
            "Hành lá, rau thơm",
            "Nước mắm, muối",
        ],
        "instructions": """
        1. Luộc gà lấy nước dùng
        2. Luộc bánh phở, để ráo
        3. Xé thịt gà
        4. Xếp bánh phở, thịt gà, hành lá vào bát
        5. Rót nước dùng nóng, thêm rau thơm
        """,
        "source": "manual",
    },
    {
        "name": "Banh Xeo",
        "vietnamese_name": "Bánh Xèo",
        "description": "Vietnamese crispy pancake",
        "category": "main",
        "serving_size_g": 200,
        "ingredients": [
            "200g bột gạo",
            "100g tôm",
            "100g thịt ba chỉ",
            "Giá đỗ, rau sống",
            "Nước mắm pha",
        ],
        "instructions": """
        1. Pha bột với nước cốt dừa
        2. Chiên bánh trên chảo nóng
        3. Cho tôm, thịt, giá vào giữa
        4. Gập bánh lại
        5. Ăn kèm rau sống và nước mắm
        """,
        "source": "manual",
    },
    {
        "name": "Cha Gio",
        "vietnamese_name": "Chả Giò",
        "description": "Vietnamese fried spring rolls",
        "category": "appetizer",
        "serving_size_g": 150,
        "ingredients": [
            "200g thịt heo xay",
            "100g tôm",
            "50g miến",
            "10 bánh tráng",
            "Rau củ, gia vị",
        ],
        "instructions": """
        1. Trộn nhân với thịt, tôm, miến, rau củ
        2. Cuốn vào bánh tráng
        3. Chiên vàng giòn
        4. Ăn kèm rau sống và nước mắm
        """,
        "source": "manual",
    },
    {
        "name": "Bun Bo Hue",
        "vietnamese_name": "Bún Bò Huế",
        "description": "Spicy beef noodle soup from Hue",
        "category": "soup",
        "serving_size_g": 450,
        "ingredients": [
            "300g thịt bò",
            "200g chả cua",
            "200g bún",
            "Sả, ớt, mắm ruốc",
            "Rau thơm",
        ],
        "instructions": """
        1. Nấu nước dùng với xương bò, sả
        2. Thêm mắm ruốc và ớt
        3. Luộc bún, thịt bò
        4. Xếp vào bát, thêm chả cua
        5. Rót nước dùng nóng
        """,
        "source": "manual",
    },
    {
        "name": "Com Tam",
        "vietnamese_name": "Cơm Tấm",
        "description": "Broken rice with grilled pork",
        "category": "main",
        "serving_size_g": 400,
        "ingredients": [
            "200g cơm tấm",
            "150g sườn heo nướng",
            "1 quả trứng ốp la",
            "Đồ chua, nước mắm",
        ],
        "instructions": """
        1. Nấu cơm tấm
        2. Nướng sườn heo
        3. Chiên trứng ốp la
        4. Xếp cơm, sườn, trứng ra đĩa
        5. Thêm đồ chua, nước mắm
        """,
        "source": "manual",
    },
    {
        "name": "Banh Cuon",
        "vietnamese_name": "Bánh Cuốn",
        "description": "Steamed rice rolls",
        "category": "main",
        "serving_size_g": 250,
        "ingredients": [
            "200g bột gạo",
            "100g thịt heo xay",
            "100g tôm khô",
            "Nước mắm pha",
            "Hành phi",
        ],
        "instructions": """
        1. Pha bột với nước
        2. Hấp bánh trên vải
        3. Cho nhân thịt tôm vào
        4. Cuốn lại
        5. Rắc hành phi, chấm nước mắm
        """,
        "source": "manual",
    },
    {
        "name": "Mi Quang",
        "vietnamese_name": "Mì Quảng",
        "description": "Quang noodles with pork and shrimp",
        "category": "main",
        "serving_size_g": 350,
        "ingredients": [
            "200g mì quảng",
            "150g thịt heo",
            "100g tôm",
            "Rau sống, đậu phộng",
            "Nước dùng",
        ],
        "instructions": """
        1. Nấu nước dùng
        2. Luộc mì, để ráo
        3. Xào thịt và tôm
        4. Xếp mì, thịt, tôm vào bát
        5. Rót ít nước dùng, thêm rau
        """,
        "source": "manual",
    },
    {
        "name": "Bun Rieu",
        "vietnamese_name": "Bún Riêu",
        "description": "Crab noodle soup",
        "category": "soup",
        "serving_size_g": 400,
        "ingredients": [
            "200g bún",
            "150g riêu cua",
            "100g đậu phụ",
            "100g chả cua",
            "Cà chua, hành lá",
        ],
        "instructions": """
        1. Nấu nước dùng cua
        2. Thêm riêu cua, cà chua
        3. Luộc bún
        4. Xếp vào bát, thêm đậu phụ, chả
        5. Rót nước dùng nóng
        """,
        "source": "manual",
    },
    {
        "name": "Banh Canh",
        "vietnamese_name": "Bánh Canh",
        "description": "Thick noodle soup",
        "category": "soup",
        "serving_size_g": 350,
        "ingredients": [
            "200g bánh canh",
            "200g tôm",
            "100g thịt heo",
            "Nước dùng",
            "Hành lá, rau thơm",
        ],
        "instructions": """
        1. Nấu nước dùng
        2. Luộc bánh canh
        3. Luộc tôm và thịt
        4. Xếp vào bát, rưới nước dùng
        5. Thêm hành lá, rau thơm
        """,
        "source": "manual",
    },
    {
        "name": "Hu Tieu",
        "vietnamese_name": "Hủ Tiếu",
        "description": "Vietnamese noodle soup",
        "category": "soup",
        "serving_size_g": 400,
        "ingredients": [
            "200g hủ tiếu",
            "150g thịt heo",
            "100g tôm",
            "Nước dùng trong",
            "Rau sống",
        ],
        "instructions": """
        1. Nấu nước dùng trong
        2. Luộc hủ tiếu, để ráo
        3. Luộc thịt và tôm
        4. Xếp vào bát, rưới nước dùng
        5. Thêm rau sống
        """,
        "source": "manual",
    },
    {
        "name": "Com Ga",
        "vietnamese_name": "Cơm Gà",
        "description": "Chicken rice",
        "category": "main",
        "serving_size_g": 350,
        "ingredients": [
            "200g gạo",
            "200g thịt gà",
            "Nước dùng gà",
            "Rau sống",
            "Nước mắm gừng",
        ],
        "instructions": """
        1. Nấu cơm với nước dùng gà
        2. Luộc gà, xé thịt
        3. Xếp cơm, thịt gà ra đĩa
        4. Thêm rau sống
        5. Chấm nước mắm gừng
        """,
        "source": "manual",
    },
    {
        "name": "Canh Chua Ca",
        "vietnamese_name": "Canh Chua Cá",
        "description": "Sour fish soup",
        "category": "soup",
        "serving_size_g": 300,
        "ingredients": [
            "300g cá",
            "Cà chua, dứa",
            "Đậu bắp, giá",
            "Me chua",
            "Rau thơm",
        ],
        "instructions": """
        1. Nấu nước dùng
        2. Thêm me, cà chua, dứa
        3. Cho cá vào nấu
        4. Thêm đậu bắp, giá
        5. Rắc rau thơm
        """,
        "source": "manual",
    },
    {
        "name": "Thit Kho Tau",
        "vietnamese_name": "Thịt Kho Tàu",
        "description": "Caramelized pork with eggs",
        "category": "main",
        "serving_size_g": 250,
        "ingredients": [
            "300g thịt ba chỉ",
            "4 quả trứng",
            "Nước dừa",
            "Nước mắm, đường",
            "Hành, tỏi",
        ],
        "instructions": """
        1. Thắng đường làm màu
        2. Xào thịt với hành tỏi
        3. Thêm nước dừa, nước mắm
        4. Luộc trứng, cho vào
        5. Kho đến khi thịt mềm
        """,
        "source": "manual",
    },
    {
        "name": "Ca Kho To",
        "vietnamese_name": "Cá Kho Tộ",
        "description": "Braised fish in clay pot",
        "category": "main",
        "serving_size_g": 200,
        "ingredients": [
            "400g cá",
            "Nước dừa",
            "Nước mắm, đường",
            "Ớt, hành",
        ],
        "instructions": """
        1. Ướp cá với gia vị
        2. Cho vào nồi đất
        3. Thêm nước dừa, nước mắm
        4. Kho nhỏ lửa
        5. Thêm ớt, hành
        """,
        "source": "manual",
    },
    {
        "name": "Rau Muong Xao Toi",
        "vietnamese_name": "Rau Muống Xào Tỏi",
        "description": "Stir-fried water spinach with garlic",
        "category": "vegetable",
        "serving_size_g": 200,
        "ingredients": [
            "300g rau muống",
            "Tỏi",
            "Dầu ăn",
            "Nước mắm",
        ],
        "instructions": """
        1. Rửa sạch rau muống
        2. Phi tỏi thơm
        3. Xào rau nhanh tay
        4. Nêm nước mắm
        5. Tắt bếp khi rau vừa chín
        """,
        "source": "manual",
    },
    {
        "name": "Tra Da",
        "vietnamese_name": "Trà Đá",
        "description": "Vietnamese iced tea",
        "category": "drink",
        "serving_size_g": 250,
        "ingredients": [
            "Trà xanh",
            "Đá viên",
            "Đường (tùy chọn)",
        ],
        "instructions": """
        1. Pha trà đặc
        2. Để nguội
        3. Thêm đá viên
        4. Thêm đường nếu muốn
        """,
        "source": "manual",
    },
    {
        "name": "Sinh To Bo",
        "vietnamese_name": "Sinh Tố Bơ",
        "description": "Avocado smoothie",
        "category": "drink",
        "serving_size_g": 300,
        "ingredients": [
            "1 quả bơ",
            "Sữa đặc",
            "Sữa tươi",
            "Đá xay",
        ],
        "instructions": """
        1. Xay bơ với sữa
        2. Thêm sữa đặc
        3. Thêm đá xay
        4. Xay mịn
        """,
        "source": "manual",
    },
    {
        "name": "Nuoc Dua",
        "vietnamese_name": "Nước Dừa",
        "description": "Fresh coconut water",
        "category": "drink",
        "serving_size_g": 300,
        "ingredients": [
            "1 quả dừa",
        ],
        "instructions": """
        1. Chặt dừa
        2. Lấy nước dừa
        3. Có thể thêm đá
        """,
        "source": "manual",
    },
    {
        "name": "Che Ba Mau",
        "vietnamese_name": "Chè Ba Màu",
        "description": "Three color dessert",
        "category": "dessert",
        "serving_size_g": 200,
        "ingredients": [
            "Đậu xanh",
            "Đậu đỏ",
            "Thạch dừa",
            "Nước cốt dừa",
            "Đá",
        ],
        "instructions": """
        1. Nấu đậu xanh, đậu đỏ
        2. Làm thạch dừa
        3. Xếp từng lớp
        4. Rưới nước cốt dừa
        5. Thêm đá
        """,
        "source": "manual",
    },
    {
        "name": "Banh Flan",
        "vietnamese_name": "Bánh Flan",
        "description": "Vietnamese caramel flan",
        "category": "dessert",
        "serving_size_g": 150,
        "ingredients": [
            "4 quả trứng",
            "200ml sữa đặc",
            "100ml sữa tươi",
            "Đường",
        ],
        "instructions": """
        1. Thắng đường làm caramel
        2. Đánh trứng với sữa
        3. Đổ vào khuôn
        4. Hấp cách thủy
        5. Để nguội, lật ngược
        """,
        "source": "manual",
    },
    {
        "name": "Xoi Xeo",
        "vietnamese_name": "Xôi Xéo",
        "description": "Turmeric sticky rice with mung bean",
        "category": "main",
        "serving_size_g": 200,
        "ingredients": [
            "200g gạo nếp",
            "50g đậu xanh",
            "Hành phi",
            "Dầu ăn",
        ],
        "instructions": """
        1. Ngâm gạo nếp với nghệ
        2. Nấu xôi
        3. Xay nhuyễn đậu xanh
        4. Xếp xôi, đậu
        5. Rắc hành phi
        """,
        "source": "manual",
    },
    {
        "name": "Banh Mi Thit Nuong",
        "vietnamese_name": "Bánh Mì Thịt Nướng",
        "description": "Vietnamese sandwich with grilled pork",
        "category": "main",
        "serving_size_g": 200,
        "ingredients": [
            "1 ổ bánh mì",
            "100g thịt nướng",
            "Pate",
            "Rau củ ngâm",
            "Nước sốt",
        ],
        "instructions": """
        1. Nướng thịt heo
        2. Cắt bánh mì
        3. Phết pate
        4. Xếp thịt, rau củ
        5. Rưới nước sốt
        """,
        "source": "manual",
    },
    {
        "name": "Com Chay",
        "vietnamese_name": "Cơm Chay",
        "description": "Vegetarian rice",
        "category": "main",
        "serving_size_g": 300,
        "ingredients": [
            "Gạo",
            "Rau củ",
            "Đậu phụ",
            "Nước tương",
        ],
        "instructions": """
        1. Nấu cơm
        2. Xào rau củ
        3. Rán đậu phụ
        4. Xếp ra đĩa
        5. Chan nước tương
        """,
        "source": "manual",
    },
]

# =====================================================================
# LOAD FOOD MAPPING FROM DATABASE
# =====================================================================
def load_food_name_map(db_config: Dict) -> Dict[str, int]:
    """Load food_id mapping from database"""
    food_map = {}
    
    try:
        conn = psycopg2.connect(**db_config)
        cursor = conn.cursor()
        
        cursor.execute("SELECT food_id, name, name_vi FROM food WHERE is_active = true")
        rows = cursor.fetchall()
        
        for food_id, name_en, name_vi in rows:
            if name_en:
                food_map[name_en.lower().strip()] = food_id
            if name_vi:
                food_map[name_vi.lower().strip()] = food_id
        
        cursor.close()
        conn.close()
        
        print(f"[OK] Loaded {len(food_map)} food name mappings from database")
        
    except Exception as e:
        print(f"[WARNING] Could not connect to database: {e}")
        print("  Will use CSV export mode only")
    
    return food_map

# =====================================================================
# PARSE INGREDIENTS AND MAP TO FOOD_ID
# =====================================================================
def parse_ingredients(
    ingredients: List[str], 
    food_name_map: Dict[str, int]
) -> List[Dict]:
    """Parse ingredient text and map to food_id"""
    parsed = []
    
    # Common Vietnamese ingredient name mappings
    ingredient_aliases = {
        "thịt bò": "beef",
        "thịt heo": "pork",
        "thịt gà": "chicken",
        "tôm": "shrimp",
        "cá": "fish",
        "trứng": "egg",
        "cà phê": "coffee",
        "sữa đặc": "condensed milk",
        "nước mắm": "fish sauce",
        "bánh phở": "rice noodles",
        "bún": "vermicelli",
        "bánh mì": "bread",
        "gạo": "rice",
        "rau": "vegetables",
        "hành": "onion",
        "tỏi": "garlic",
        "ớt": "chili",
        "gừng": "ginger",
        "chanh": "lemon",
        "nước": "water",
    }
    
    for ing_text in ingredients:
        if not ing_text or len(ing_text) < 3:
            continue
        
        # Extract weight
        weight_g = parse_weight(ing_text)
        
        # Extract ingredient name (remove weight info)
        ing_name = re.sub(r'\d+\.?\d*\s*(g|kg|ml|l|gram|kilogram|litre|lit)', '', ing_text, flags=re.IGNORECASE)
        ing_name = normalize_text(ing_name)
        
        # Remove common words
        ing_name = re.sub(r'\s*(khoảng|tầm|chừng|một|hai|ba|bốn|năm|sáu|bảy|tám|chín|mười)\s+', '', ing_name, flags=re.IGNORECASE)
        ing_name = re.sub(r'\s*(củ|quả|trái|nhánh|lá|nhánh|miếng|con|tép)\s+', '', ing_name)
        ing_name = normalize_text(ing_name)
        
        if not ing_name:
            continue
        
        # Try to find food_id
        food_id = get_food_id_from_name(ing_name, food_name_map)
        
        # Also try with aliases
        if not food_id:
            for vi_name, en_name in ingredient_aliases.items():
                if vi_name in ing_name.lower():
                    food_id = get_food_id_from_name(en_name, food_name_map)
                    if food_id:
                        break
        
        # Default weight if not parsed
        if not weight_g:
            weight_g = 50.0  # Default estimate
        
        parsed.append({
            "ingredient_name": ing_name,
            "food_id": food_id,
            "weight_g": weight_g,
            "original_text": ing_text,
        })
    
    return parsed

# =====================================================================
# MAIN SCRAPING FUNCTION
# =====================================================================
def fetch_all_recipes(max_per_source: int = 100, use_dataset: bool = True) -> List[Dict]:
    """Fetch recipes from all enabled sources"""
    all_recipes = []
    
    print("="*60)
    print("FETCHING VIETNAMESE RECIPES")
    print("="*60)
    
    # Load from SQL file (extended_tables_vietnam.sql) - contains real recipes
    print(f"\n[1/8] Loading recipes from extended_tables_vietnam.sql...")
    sql_recipes = load_recipes_from_sql()
    all_recipes.extend(sql_recipes)
    print(f"  [OK] Added {len(sql_recipes)} recipes from SQL file")
    
    # Load from Vietnamese food dataset (has nutrition data but no recipes)
    if use_dataset:
        print(f"\n[2/8] Loading Vietnamese food dataset...")
        dataset_recipes = load_vietnamese_food_dataset()
        all_recipes.extend(dataset_recipes)
        print(f"  [OK] Added {len(dataset_recipes)} foods from dataset")
    
    # Add manual recipes (with full recipe details)
    print(f"\n[3/8] Loading manual recipes...")
    all_recipes.extend(MANUAL_RECIPES)
    print(f"  [OK] Added {len(MANUAL_RECIPES)} manual recipes")
    
    # Scrape Cooky.vn (most popular) - disabled if websites not accessible
    if RECIPE_SOURCES['cooky']['enabled']:
        print(f"\n[4/8] Scraping Cooky.vn...")
        cooky_recipes = scrape_cooky_recipes(max_per_source)
        all_recipes.extend(cooky_recipes)
        print(f"  [OK] Scraped {len(cooky_recipes)} recipes from Cooky.vn")
    
    # Scrape AmThuc365.vn
    if RECIPE_SOURCES['amthuc365']['enabled']:
        print(f"\n[5/8] Scraping AmThuc365.vn...")
        at365_recipes = scrape_amthuc365_recipes(max_per_source)
        all_recipes.extend(at365_recipes)
        print(f"  [OK] Scraped {len(at365_recipes)} recipes from AmThuc365.vn")
    
    # Scrape VOV
    if RECIPE_SOURCES['vov']['enabled']:
        print(f"\n[6/8] Scraping VOV.vn...")
        vov_recipes = scrape_vov_recipes(max_per_source)
        all_recipes.extend(vov_recipes)
        print(f"  [OK] Scraped {len(vov_recipes)} recipes from VOV")
    
    # Scrape MonNgonViet
    if RECIPE_SOURCES['monngonviet']['enabled']:
        print(f"\n[7/8] Scraping MonNgonViet.com.vn...")
        mnv_recipes = scrape_monngonviet_recipes(max_per_source)
        all_recipes.extend(mnv_recipes)
        print(f"  [OK] Scraped {len(mnv_recipes)} recipes from MonNgonViet")
    
    # Deduplicate by name
    seen_names = set()
    unique_recipes = []
    for recipe in all_recipes:
        name_key = recipe.get('vietnamese_name', '').lower().strip()
        if name_key and name_key not in seen_names:
            seen_names.add(name_key)
            unique_recipes.append(recipe)
    
    print(f"\n[8/8] Summary:")
    print(f"  Total recipes fetched: {len(all_recipes)}")
    print(f"  Unique recipes: {len(unique_recipes)}")
    
    return unique_recipes

# =====================================================================
# EXPORT TO CSV/SQL
# =====================================================================
def write_table_files(table_name: str, csv_header: List[str], csv_rows: List[Dict], table_folder: Optional[Path] = None):
    """
    Write CSV and SQL files for a table in its own folder.
    
    Args:
        table_name: Name of the table (e.g., 'dish', 'drink')
        csv_header: List of column names
        csv_rows: List of dictionaries with data
        table_folder: Optional folder path (defaults to OUTPUT_DIR / table_name)
    """
    if not csv_rows:
        return
    
    # Create table folder
    if table_folder is None:
        table_folder = OUTPUT_DIR / table_name
    table_folder.mkdir(parents=True, exist_ok=True)
    
    # Write CSV file
    csv_file = table_folder / f"{table_name}.csv"
    with open(csv_file, 'w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=csv_header)
        writer.writeheader()
        for row in csv_rows:
            # Clean data - replace None with empty string
            cleaned_row = {k: (v if v is not None else '') for k, v in row.items()}
            writer.writerow(cleaned_row)
    
    # Generate SQL import script
    sql_file = table_folder / f"{table_name}.sql"
    csv_columns = ', '.join(csv_header)
    csv_path = csv_file.resolve().as_posix()
    
    with open(sql_file, 'w', encoding='utf-8') as f:
        f.write(f"-- Import {table_name} table from CSV\n")
        f.write(f"-- CSV file: {table_name}.csv\n")
        f.write(f"-- Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"-- Total rows: {len(csv_rows)}\n\n")
        f.write("-- Option 1: Using PostgreSQL COPY command (recommended)\n")
        f.write("BEGIN;\n\n")
        f.write("-- Create temporary table with same structure\n")
        f.write(f"CREATE TEMP TABLE tmp_{table_name} (LIKE {table_name} INCLUDING ALL);\n\n")
        f.write("-- Copy data from CSV\n")
        f.write(f"\\copy tmp_{table_name} ({csv_columns})\n")
        f.write(f"FROM '{csv_path}'\n")
        f.write("WITH (FORMAT csv, HEADER true, DELIMITER ',');\n\n")
        f.write("-- Optional: Delete existing data before inserting\n")
        f.write(f"-- DELETE FROM {table_name};\n\n")
        f.write("-- Insert new data (using ON CONFLICT for tables with unique constraints)\n")
        f.write(f"INSERT INTO {table_name} ({csv_columns})\n")
        f.write(f"SELECT {csv_columns}\n")
        f.write(f"FROM tmp_{table_name}\n")
        f.write("ON CONFLICT DO NOTHING;\n\n")
        f.write("-- For tables without unique constraints, use simple INSERT:\n")
        f.write(f"-- INSERT INTO {table_name} ({csv_columns})\n")
        f.write(f"-- SELECT {csv_columns} FROM tmp_{table_name};\n\n")
        f.write(f"DROP TABLE tmp_{table_name};\n\n")
        f.write("COMMIT;\n\n")
        f.write("-- Verification query\n")
        f.write(f"SELECT COUNT(*) AS total_rows_in_{table_name} FROM {table_name};\n\n")
        f.write("-- Option 2: Using relative path (if running from table folder)\n")
        f.write("/*\n")
        f.write(f"\\copy tmp_{table_name} ({csv_columns})\n")
        f.write(f"FROM './{table_name}.csv'\n")
        f.write("WITH (FORMAT csv, HEADER true, DELIMITER ',');\n")
        f.write("*/\n")
    
    print(f"  [OK] Created {table_name}/ folder with {len(csv_rows)} rows")
    print(f"       -> {csv_file.name}")
    print(f"       -> {sql_file.name}")

def export_to_csv(recipes: List[Dict], food_name_map: Dict[str, int]):
    """Export recipes to CSV files matching database schema"""
    
    # Separate dishes and drinks
    dishes = []
    drinks = []
    dish_ingredients = []
    drink_ingredients = []
    
    # Start IDs from max existing IDs + 1
    max_dish_id = max([r.get('dish_id', 0) for r in recipes if 'dish_id' in r], default=0)
    max_drink_id = max([r.get('drink_id', 0) for r in recipes if 'drink_id' in r], default=0)
    
    dish_id = max(max_dish_id + 1, 1)
    drink_id = max(max_drink_id + 1, 1)
    
    for recipe in recipes:
        category = recipe.get('category', '').lower()
        
        # Parse ingredients
        parsed_ings = parse_ingredients(recipe.get('ingredients', []), food_name_map)
        
        # Check if recipe already has drink_id (from SQL)
        if 'drink_id' in recipe:
            drink_id_to_use = recipe['drink_id']
        elif category == 'drink' or 'nước' in recipe.get('vietnamese_name', '').lower():
            drink_id_to_use = drink_id
            drink_id += 1
        else:
            drink_id_to_use = None
        
        # Check if recipe already has dish_id (from SQL)
        if 'dish_id' in recipe:
            dish_id_to_use = recipe['dish_id']
        else:
            dish_id_to_use = dish_id
            dish_id += 1
        
        if drink_id_to_use is not None:
            # Add as drink
            drinks.append({
                "drink_id": drink_id_to_use,
                "name": recipe.get('name', ''),
                "vietnamese_name": recipe.get('vietnamese_name', ''),
                "description": recipe.get('description', ''),
                "category": category or "beverage",
                "default_volume_ml": recipe.get('serving_size_g', 250),
                "image_url": recipe.get('image_url', ''),
                "is_template": True,
                "is_public": True,
                "created_by_admin": 1,
                "source_url": recipe.get('source_url', ''),
            })
            
            # Add drink ingredients
            for idx, ing in enumerate(parsed_ings):
                if ing['food_id']:
                    drink_ingredients.append({
                        "drink_id": drink_id_to_use,
                        "food_id": ing['food_id'],
                        "amount_g": ing['weight_g'],
                        "unit": "g",
                        "display_order": idx + 1,
                        "notes": ing['ingredient_name'],
                    })
        else:
            # Add as dish
            dishes.append({
                "dish_id": dish_id_to_use,
                "name": recipe.get('name', ''),
                "vietnamese_name": recipe.get('vietnamese_name', ''),
                "description": recipe.get('description', ''),
                "category": category or "main",
                "serving_size_g": recipe.get('serving_size_g', 200),
                "image_url": recipe.get('image_url', ''),
                "is_template": True,
                "is_public": True,
                "created_by_admin": 1,
                "instructions": recipe.get('instructions', ''),
                "source_url": recipe.get('source_url', ''),
            })
            
            # Add dish ingredients
            for idx, ing in enumerate(parsed_ings):
                if ing['food_id']:
                    dish_ingredients.append({
                        "dish_id": dish_id_to_use,
                        "food_id": ing['food_id'],
                        "weight_g": ing['weight_g'],
                        "display_order": idx + 1,
                        "notes": ing['ingredient_name'],
                    })
    
    # Write files for each table
    print(f"\n{'='*60}")
    print("EXPORTING TO CSV/SQL")
    print(f"{'='*60}")
    
    # Export dishes
    if dishes:
        write_table_files(
            table_name="dish",
            csv_header=['dish_id', 'name', 'vietnamese_name', 'description', 'category',
                       'serving_size_g', 'image_url', 'is_template', 'is_public',
                       'created_by_admin', 'instructions', 'source_url'],
            csv_rows=dishes
        )
    
    # Export dish ingredients
    if dish_ingredients:
        write_table_files(
            table_name="dishingredient",
            csv_header=['dish_id', 'food_id', 'weight_g', 'display_order', 'notes'],
            csv_rows=dish_ingredients
        )
    
    # Export drinks
    if drinks:
        write_table_files(
            table_name="drink",
            csv_header=['drink_id', 'name', 'vietnamese_name', 'description', 'category',
                       'default_volume_ml', 'image_url', 'is_template', 'is_public',
                       'created_by_admin', 'source_url'],
            csv_rows=drinks
        )
    
    # Export drink ingredients
    if drink_ingredients:
        write_table_files(
            table_name="drinkingredient",
            csv_header=['drink_id', 'food_id', 'amount_g', 'unit', 'display_order', 'notes'],
            csv_rows=drink_ingredients
        )
    
    print(f"\n{'='*60}")
    print("EXPORT COMPLETE!")
    print(f"{'='*60}")
    print(f"Output directory: {OUTPUT_DIR}")
    print(f"Total dishes: {len(dishes)}")
    print(f"Total drinks: {len(drinks)}")
    print(f"Total dish ingredients: {len(dish_ingredients)}")
    print(f"Total drink ingredients: {len(drink_ingredients)}")
    print(f"\nStructure:")
    print(f"  {OUTPUT_DIR}/")
    if dishes:
        print(f"    dish/")
        print(f"      dish.csv")
        print(f"      dish.sql")
    if dish_ingredients:
        print(f"    dishingredient/")
        print(f"      dishingredient.csv")
        print(f"      dishingredient.sql")
    if drinks:
        print(f"    drink/")
        print(f"      drink.csv")
        print(f"      drink.sql")
    if drink_ingredients:
        print(f"    drinkingredient/")
        print(f"      drinkingredient.csv")
        print(f"      drinkingredient.sql")

# =====================================================================
# MAIN
# =====================================================================
if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Fetch Vietnamese recipes and export to database format")
    parser.add_argument("--max-per-source", type=int, default=50, help="Max recipes per source")
    parser.add_argument("--manual-only", action="store_true", help="Use only manual recipes (skip web scraping)")
    parser.add_argument("--skip-db", action="store_true", help="Skip database connection (export CSV only)")
    args = parser.parse_args()
    
    # Load food mapping (optional)
    food_name_map = {}
    if not args.skip_db:
        food_name_map = load_food_name_map(DB_CONFIG)
    
    # Fetch recipes
    if args.manual_only:
        recipes = MANUAL_RECIPES
        print("Using manual recipes only")
    else:
        # Load from all available sources (SQL file, dataset, manual recipes)
        # Web scraping will be attempted but may fail if sites are down
        recipes = fetch_all_recipes(max_per_source=args.max_per_source, use_dataset=True)
    
    # Export to CSV/SQL
    export_to_csv(recipes, food_name_map)
    
    print("\n[SUCCESS] All done!")


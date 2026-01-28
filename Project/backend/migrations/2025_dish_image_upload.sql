-- ============================================================
-- DISH IMAGE UPLOAD SUPPORT
-- Add support for multiple images per dish
-- Date: 2025-11-15
-- ============================================================

BEGIN;

-- Add image_urls column to dish table (JSON array of image URLs)
ALTER TABLE dish ADD COLUMN IF NOT EXISTS image_urls JSONB DEFAULT '[]';

-- Update existing dishes to have their image_url in the array
UPDATE dish 
SET image_urls = CASE 
  WHEN image_url IS NOT NULL AND image_url != '' 
  THEN jsonb_build_array(image_url)
  ELSE '[]'::jsonb
END
WHERE image_urls = '[]'::jsonb;

-- Comment for future: image_url is kept for backward compatibility
-- New uploads should use image_urls array

COMMIT;

SELECT 'Dish image upload support added!' as status;

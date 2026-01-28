-- Seed canonical vitamins and minerals used by the app UI
-- Depends on structural DDL in schema.sql (Vitamin, Mineral and helpers)

BEGIN;

-- Vitamins list: A, D, E, K, C, B1, B2, B3, B5, B6, B7, B9, B12
-- Uses helper upsert function to ensure idempotent inserts/updates
SELECT seed_core_vitamins();

-- Minerals list: CA, P, MG, K, NA, FE, ZN, CU, MN, I, SE, CR, MO, F
SELECT seed_core_minerals();

COMMIT;

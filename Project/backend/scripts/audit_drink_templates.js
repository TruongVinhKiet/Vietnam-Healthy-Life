const fs = require('fs');
const path = require('path');

const db = require('../db');

async function main() {
  const tables = ['drink', 'drinkingredient', 'drinknutrient', 'food', 'foodnutrient', 'nutrient'];
  const tableCols = {};

  for (const t of tables) {
    const cols = await db.query(
      `SELECT column_name, data_type
       FROM information_schema.columns
       WHERE table_name = $1
       ORDER BY ordinal_position`,
      [t]
    );
    tableCols[t] = cols.rows;
  }

  console.log('=== Table columns (subset) ===');
  for (const t of ['drinkingredient', 'drink', 'drinknutrient']) {
    console.log(`\n-- ${t} --`);
    console.table(tableCols[t]);
  }

  const stats = await db.query(
    `SELECT
       COUNT(*)::int AS templates,
       SUM(CASE WHEN NOT EXISTS (SELECT 1 FROM drinkingredient di WHERE di.drink_id = d.drink_id) THEN 1 ELSE 0 END)::int AS templates_missing_ingredients,
       SUM(CASE WHEN NOT EXISTS (SELECT 1 FROM drinknutrient dn WHERE dn.drink_id = d.drink_id) THEN 1 ELSE 0 END)::int AS templates_missing_nutrients
     FROM drink d
     WHERE d.is_template = TRUE`
  );

  console.log('\n=== Drink template coverage ===');
  console.table(stats.rows);

  const missingIngredients = await db.query(
    `SELECT d.drink_id, d.slug, d.name, d.vietnamese_name, d.category, d.base_liquid, d.default_volume_ml
     FROM drink d
     WHERE d.is_template = TRUE
       AND NOT EXISTS (SELECT 1 FROM drinkingredient di WHERE di.drink_id = d.drink_id)
     ORDER BY d.drink_id`
  );

  console.log(`\n=== Templates missing ingredients (${missingIngredients.rows.length}) ===`);
  console.table(missingIngredients.rows);

  const missingNutrients = await db.query(
    `SELECT d.drink_id, d.slug, d.name, d.vietnamese_name, d.category
     FROM drink d
     WHERE d.is_template = TRUE
       AND NOT EXISTS (SELECT 1 FROM drinknutrient dn WHERE dn.drink_id = d.drink_id)
     ORDER BY d.drink_id`
  );

  console.log(`\n=== Templates missing nutrients (${missingNutrients.rows.length}) ===`);
  console.table(missingNutrients.rows);

  const missingIngredientIds = new Set(missingIngredients.rows.map((r) => r.drink_id));
  const missingNutrientIds = new Set(missingNutrients.rows.map((r) => r.drink_id));
  const intersection = missingIngredients.rows.filter((r) => missingNutrientIds.has(r.drink_id));

  console.log(`\n=== Templates missing BOTH ingredients and nutrients (${intersection.length}) ===`);
  console.table(intersection);

  const fnMissing = await db.query(
    `SELECT f.food_id, COALESCE(f.name_vi, f.name) AS name, f.category
     FROM (
       SELECT DISTINCT di.food_id
       FROM drinkingredient di
       JOIN drink d ON d.drink_id = di.drink_id
       WHERE d.is_template = TRUE
     ) x
     JOIN food f ON f.food_id = x.food_id
     WHERE NOT EXISTS (SELECT 1 FROM foodnutrient fn WHERE fn.food_id = f.food_id)
     ORDER BY f.food_id`
  );

  console.log(`\n=== Ingredient foods missing FoodNutrient (${fnMissing.rows.length}) ===`);
  console.table(fnMissing.rows);

  const calcFn = await db.query(
    `SELECT p.proname
     FROM pg_proc p
     WHERE p.proname IN ('calculate_drink_nutrients', 'calculate_dish_nutrients')
     ORDER BY p.proname`
  );
  console.log('\n=== Calc functions present ===');
  console.table(calcFn.rows);

  const out = {
    generated_at: new Date().toISOString(),
    template_stats: stats.rows[0],
    missing_ingredients: missingIngredients.rows,
    missing_nutrients: missingNutrients.rows,
    missing_both: intersection,
    ingredient_foods_missing_nutrients: fnMissing.rows,
    calc_functions_present: calcFn.rows,
  };

  const outPath = path.resolve(__dirname, '../drink_template_audit.json');
  fs.writeFileSync(outPath, JSON.stringify(out, null, 2), 'utf8');
  console.log(`\nWrote full audit to: ${outPath}`);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });

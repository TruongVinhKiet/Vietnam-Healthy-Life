const db = require('../db');

function pct(n, d) {
  if (!d || d <= 0) return 0;
  return Math.round((n / d) * 10000) / 100;
}

async function getScalar(sql, params = []) {
  const res = await db.query(sql, params);
  const row = res.rows[0] || {};
  const v = Object.values(row)[0];
  return typeof v === 'string' ? Number(v) : v;
}

async function groupNutrientIds(whereSql, params = []) {
  const res = await db.query(
    `SELECT nutrient_id, nutrient_code, group_name FROM nutrient WHERE ${whereSql} ORDER BY nutrient_code`,
    params
  );
  return res.rows;
}

async function coverageFor(tableName, keyColumn, nutrientIds) {
  if (!nutrientIds.length) {
    return { itemsWithAny: 0, totalRows: 0 };
  }

  const itemsWithAny = await getScalar(
    `SELECT COUNT(DISTINCT ${keyColumn})::int AS c FROM ${tableName} WHERE nutrient_id = ANY($1::int[])`,
    [nutrientIds]
  );
  const totalRows = await getScalar(
    `SELECT COUNT(*)::int AS c FROM ${tableName} WHERE nutrient_id = ANY($1::int[])`,
    [nutrientIds]
  );

  return { itemsWithAny: Number(itemsWithAny) || 0, totalRows: Number(totalRows) || 0 };
}

async function perNutrientFoodCounts(whereSql, params = []) {
  const res = await db.query(
    `
    SELECT n.nutrient_code,
           COUNT(DISTINCT fn.food_id)::int AS foods_with
    FROM nutrient n
    LEFT JOIN foodnutrient fn ON fn.nutrient_id = n.nutrient_id
    WHERE ${whereSql}
    GROUP BY n.nutrient_code
    ORDER BY foods_with ASC, n.nutrient_code ASC
  `,
    params
  );
  return res.rows;
}

async function main() {
  const totalFoods = await getScalar('SELECT COUNT(*)::int AS c FROM food');
  const totalDishes = await getScalar('SELECT COUNT(*)::int AS c FROM dish');
  const totalDrinks = await getScalar('SELECT COUNT(*)::int AS c FROM drink');

  console.log('NUTRIENT COVERAGE REPORT');
  console.log('='.repeat(80));
  console.log('Totals:');
  console.log(`- foods:  ${totalFoods}`);
  console.log(`- dishes: ${totalDishes}`);
  console.log(`- drinks: ${totalDrinks}`);

  const groups = [
    {
      name: 'Vitamins',
      where: `group_name = 'Vitamins'`,
      examplesLimit: 15
    },
    {
      name: 'Minerals',
      where: `group_name = 'Minerals'`,
      examplesLimit: 15
    },
    {
      name: 'Dietary Fiber',
      where: `group_name = 'Dietary Fiber' OR UPPER(nutrient_code) IN ('FIBTG','FIB_SOL','FIB_INSOL','FIB_RS','FIB_BGLU')`,
      examplesLimit: 10
    },
    {
      name: 'Amino acids',
      where: `group_name = 'Amino acids' OR UPPER(nutrient_code) LIKE 'AMINO_%'`,
      examplesLimit: 10
    },
    {
      name: 'Fat / Fatty acids',
      where: `group_name = 'Fat / Fatty acids' OR UPPER(nutrient_code) IN ('FAT','FASAT','FAMS','FAPU','FA18_3N3','FAEPA','FADHA','FAEPA_DHA','FA18_2N6C','FATRN','CHOLESTEROL')`,
      examplesLimit: 10
    },
    {
      name: 'Water',
      where: `UPPER(nutrient_code) = 'WATER'`,
      examplesLimit: 1
    }
  ];

  for (const g of groups) {
    const nutrients = await groupNutrientIds(g.where);
    const nutrientIds = nutrients.map((n) => n.nutrient_id);

    const foodCov = await coverageFor('foodnutrient', 'food_id', nutrientIds);
    const dishCov = await coverageFor('dishnutrient', 'dish_id', nutrientIds);
    const drinkCov = await coverageFor('drinknutrient', 'drink_id', nutrientIds);

    console.log('\n' + '-'.repeat(80));
    console.log(`${g.name}`);
    console.log(`- nutrients in group: ${nutrients.length}`);
    console.log(
      `- FoodNutrient: foods_with_any=${foodCov.itemsWithAny}/${totalFoods} (${pct(foodCov.itemsWithAny, totalFoods)}%), rows=${foodCov.totalRows}`
    );
    console.log(
      `- DishNutrient: dishes_with_any=${dishCov.itemsWithAny}/${totalDishes} (${pct(dishCov.itemsWithAny, totalDishes)}%), rows=${dishCov.totalRows}`
    );
    console.log(
      `- DrinkNutrient: drinks_with_any=${drinkCov.itemsWithAny}/${totalDrinks} (${pct(drinkCov.itemsWithAny, totalDrinks)}%), rows=${drinkCov.totalRows}`
    );

    const perNutrient = await perNutrientFoodCounts(g.where);
    const worst = perNutrient.slice(0, g.examplesLimit);
    if (worst.length > 0) {
      console.log('- lowest coverage nutrients (foods_with):');
      worst.forEach((r) => {
        console.log(`  - ${r.nutrient_code}: ${r.foods_with}`);
      });
    }
  }

  console.log('\n' + '='.repeat(80));
  console.log('Done.');
  process.exit(0);
}

main().catch((e) => {
  console.error('ERROR:', e && e.message);
  process.exit(1);
});

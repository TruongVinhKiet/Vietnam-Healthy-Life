
const { Pool } = require('pg');
require('dotenv').config();

// Delay creating DB pool until we actually need to connect. This allows
// dry-run mode to run even if DB env vars are missing or invalid.
let pool = null;
function createPoolIfNeeded() {
	if (pool) return pool;
	// Validate basic env presence to avoid pg throwing cryptic errors
	const host = process.env.DB_HOST;
	const user = process.env.DB_USER;
	const password = process.env.DB_PASSWORD;
	const database = process.env.DB_NAME;
	const port = process.env.DB_PORT;

	if (!host || !user || !password || !database) {
		throw new Error('Database environment variables not fully set (DB_HOST, DB_USER, DB_PASSWORD, DB_NAME required)');
	}

	pool = new Pool({ host, port, database, user, password });
	return pool;
}

async function main() {
	const args = process.argv.slice(2);
	const confirm = args.includes('--confirm');
	console.log('apply_1000_to_ultra.js - dry run unless --confirm is supplied');

		let client = null;
		// Only attempt to connect when necessary (confirm=true) or when DB env present
		try {
			if (confirm) {
				const p = createPoolIfNeeded();
				client = await p.connect();
			} else {
				// dry-run: if DB config is present we may connect to show real counts; otherwise simulate
				if (process.env.DB_HOST && process.env.DB_USER && process.env.DB_PASSWORD && process.env.DB_NAME) {
					try {
						const p = createPoolIfNeeded();
						client = await p.connect();
					} catch (e) {
						console.log('[dry-run] DB connection failed:', e.message);
						client = null;
					}
				} else {
					client = null;
				}
			}
		} catch (e) {
			console.error('DB setup error:', e.message);
			client = null;
		}
		// If client is null, we will simulate dry-run and avoid DB calls
		if (!client && !confirm) {
			console.log('[dry-run] No DB connection; simulating actions.');
			console.log("Looking for existing food named: Ultra Food (1000) -> (would search DB)");
			console.log('[dry-run] Would upsert FoodNutrient rows for all nutrients to 1000 (count unknown without DB)');
			console.log('[dry-run] Would create or upsert Dish "Ultra Dish (1000)" and link Ultra Food as 100g ingredient');
			console.log('\nDry-run complete. To run against your DB set DB_HOST, DB_USER, DB_PASSWORD, DB_NAME and re-run (or run with --confirm to apply).');
			return;
		}
	try {
		await client.query('BEGIN');

		const foodName = 'Ultra Food (1000)';
		console.log('Looking for existing food named:', foodName);

		// Helper to get columns for a table (public schema)
		async function getTableColumns(tbl) {
			const q = `SELECT column_name FROM information_schema.columns WHERE table_schema = 'public' AND table_name = $1`;
			const r = await client.query(q, [tbl.toLowerCase()]);
			return r.rows.map(r => r.column_name);
		}

		// Inspect Food columns and perform schema-aware insert
		const foodCols = await getTableColumns('food');
		let res = await client.query('SELECT food_id FROM food WHERE name = $1 LIMIT 1', [foodName]);
		let foodId;
		if (res.rows.length > 0) {
			foodId = res.rows[0].food_id;
			console.log('Found existing food id =', foodId);
		} else {
			console.log('No existing food found. Creating new Food row.');
			if (confirm) {
				// Build dynamic insert based on available columns
				const insertCols = ['name'];
				const insertVals = ['$1'];
				const params = [foodName];

				if (foodCols.includes('name_vi')) { insertCols.push('name_vi'); insertVals.push(`$${insertVals.length + 1}`); params.push('Thực phẩm Ultra (1000)'); }
				if (foodCols.includes('category')) { insertCols.push('category'); insertVals.push(`$${insertVals.length + 1}`); params.push('ultra'); }
				if (foodCols.includes('description')) { insertCols.push('description'); insertVals.push(`$${insertVals.length + 1}`); params.push('Synthetic ultra food with 1000 value for every nutrient (admin use only)'); }

				const insertQ = `INSERT INTO food (${insertCols.join(',')}) VALUES (${insertVals.join(',')}) RETURNING food_id`;
				res = await client.query(insertQ, params);
				foodId = res.rows[0].food_id;
				console.log('Inserted Food id =', foodId);
			} else {
				console.log('[dry-run] Would INSERT Food row here.');
			}
		}

		// Fetch all nutrients
		const nutrientsRes = await client.query('SELECT nutrient_id, nutrient_code, name FROM Nutrient ORDER BY nutrient_id');
		const nutrients = nutrientsRes.rows;
		console.log('Found', nutrients.length, 'nutrients in system.');

		// Upsert FoodNutrient rows to 1000 per 100g
		if (nutrients.length > 0) {
			if (!confirm) {
				console.log('[dry-run] Would upsert', nutrients.length, 'FoodNutrient rows with amount_per_100g=1000');
			} else {
				console.log('Upserting FoodNutrient rows...');
				for (const n of nutrients) {
					await client.query(`
						INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
						VALUES ($1, $2, $3)
						ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g
					`, [foodId, n.nutrient_id, 1000]);
				}
				console.log('Upserted FoodNutrient rows to 1000.');
			}
		}

		// Create or find Dish (schema-aware)
		const dishName = 'Ultra Dish (1000)';
		const dishCols = await getTableColumns('dish');
		res = await client.query('SELECT dish_id FROM dish WHERE name = $1 LIMIT 1', [dishName]);
		let dishId;
		if (res.rows.length > 0) {
			dishId = res.rows[0].dish_id;
			console.log('Found existing Dish id =', dishId);
		} else {
			console.log('No existing Dish found. Creating new Dish row.');
			if (confirm) {
				const insertCols = ['name'];
				const insertVals = ['$1'];
				const params = [dishName];

				if (dishCols.includes('description')) { insertCols.push('description'); insertVals.push(`$${insertVals.length + 1}`); params.push('Dish composed solely of Ultra Food (1000) for testing/admin'); }
				if (dishCols.includes('category')) { insertCols.push('category'); insertVals.push(`$${insertVals.length + 1}`); params.push('ultra'); }
				if (dishCols.includes('serving_size_g')) { insertCols.push('serving_size_g'); insertVals.push(`$${insertVals.length + 1}`); params.push(100); }
				if (dishCols.includes('is_template')) { insertCols.push('is_template'); insertVals.push(`$${insertVals.length + 1}`); params.push(true); }
				if (dishCols.includes('is_public')) { insertCols.push('is_public'); insertVals.push(`$${insertVals.length + 1}`); params.push(true); }

				const insertQ = `INSERT INTO dish (${insertCols.join(',')}) VALUES (${insertVals.join(',')}) RETURNING dish_id`;
				res = await client.query(insertQ, params);
				dishId = res.rows[0].dish_id;
				console.log('Inserted Dish id =', dishId);
			} else {
				console.log('[dry-run] Would INSERT Dish row here.');
			}
		}

		// Add DishIngredient linking the dish to the ultra food (weight 100g)
		if (dishId && foodId) {
			console.log('Upserting DishIngredient linking dish -> food with weight 100g');
			if (!confirm) {
				console.log('[dry-run] Would INSERT/UPDATE DishIngredient (dish_id, food_id, weight_g = 100)');
			} else {
				await client.query(`
					INSERT INTO DishIngredient (dish_id, food_id, weight_g, display_order)
					VALUES ($1, $2, $3, $4)
					ON CONFLICT (dish_id, food_id) DO UPDATE SET weight_g = EXCLUDED.weight_g, display_order = EXCLUDED.display_order
				`, [dishId, foodId, 100, 0]);

				// Force recalculation in case trigger not fired synchronously
				try {
					await client.query('SELECT calculate_dish_nutrients($1)', [dishId]);
					console.log('Called calculate_dish_nutrients for dish', dishId);
				} catch (e) {
					console.warn('Failed to call calculate_dish_nutrients (function may not exist):', e.message);
				}
			}
		}

		if (!confirm) {
			await client.query('ROLLBACK');
			console.log('\nDry-run complete. No changes were written.');
			console.log('To apply changes, re-run with:');
			console.log('  node apply_1000_to_ultra.js --confirm');
		} else {
			await client.query('COMMIT');
			console.log('\nChanges committed. Ultra food and dish should be present.');
			console.log('Summary:');
			console.log('- Food id:', foodId);
			console.log('- Dish id:', dishId);
			console.log('- FoodNutrient rows set to 1000 for', nutrients.length, 'nutrients');
		}

	} catch (err) {
		await client.query('ROLLBACK');
		console.error('Error during operation:', err);
	} finally {
		client.release();
		await pool.end();
	}
}

if (require.main === module) {
	main().catch(err => {
		console.error('Unhandled error:', err);
		process.exit(1);
	});
}

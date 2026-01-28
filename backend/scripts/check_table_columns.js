const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({ connectionString: process.env.DATABASE_URL });

async function checkColumns() {
    try {
        const dishCols = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'dish' 
            ORDER BY ordinal_position
        `);
        console.log('DISH COLUMNS:', dishCols.rows.map(x => x.column_name).join(', '));

        const drinkCols = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'drink' 
            ORDER BY ordinal_position
        `);
        console.log('DRINK COLUMNS:', drinkCols.rows.map(x => x.column_name).join(', '));

        const userSettingCols = await pool.query(`
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = 'usersetting' 
            ORDER BY ordinal_position
        `);
        console.log('USERSETTING COLUMNS:', userSettingCols.rows.map(x => x.column_name).join(', '));

        await pool.end();
    } catch (e) {
        console.error(e);
        await pool.end();
    }
}

checkColumns();

require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: String(process.env.DB_PASSWORD || ''),
  database: process.env.DB_DATABASE || 'Health',
});

async function comprehensiveAudit() {
  const client = await pool.connect();
  
  try {
    console.log('\n' + '='.repeat(80));
    console.log('🔍 COMPREHENSIVE DATABASE & API AUDIT');
    console.log('='.repeat(80) + '\n');

    // ========================================================================
    // PART 1: SCAN ALL ROUTE FILES TO FIND API ENDPOINTS
    // ========================================================================
    console.log('📡 PART 1: API ENDPOINTS ANALYSIS');
    console.log('━'.repeat(80));
    
    const routesDir = path.join(__dirname, 'routes');
    const routeFiles = fs.readdirSync(routesDir).filter(f => f.endsWith('.js'));
    
    const apiEndpoints = [];
    const tableReferences = new Set();
    
    for (const file of routeFiles) {
      const content = fs.readFileSync(path.join(routesDir, file), 'utf8');
      const routeName = file.replace('.js', '');
      
      // Extract route definitions
      const routeMatches = content.match(/router\.(get|post|put|delete|patch)\(['"`]([^'"`]+)/g);
      
      if (routeMatches) {
        routeMatches.forEach(match => {
          const [, method, route] = match.match(/router\.(\w+)\(['"`]([^'"`]+)/);
          apiEndpoints.push({
            file: routeName,
            method: method.toUpperCase(),
            route: route,
            fullPath: `/${routeName}${route}`
          });
        });
      }
      
      // Extract table references from queries
      const tableMatches = content.match(/FROM\s+["']?(\w+)["']?|JOIN\s+["']?(\w+)["']?|INTO\s+["']?(\w+)["']?|UPDATE\s+["']?(\w+)["']?/gi);
      if (tableMatches) {
        tableMatches.forEach(match => {
          const tableName = match.replace(/FROM|JOIN|INTO|UPDATE|["'`\s]/gi, '').trim();
          if (tableName && tableName.length > 0) {
            tableReferences.add(tableName);
          }
        });
      }
    }
    
    console.log(`\n✓ Found ${apiEndpoints.length} API endpoints across ${routeFiles.length} route files`);
    console.log(`✓ Found ${tableReferences.size} table references in queries\n`);
    
    // Group by route file
    const groupedEndpoints = {};
    apiEndpoints.forEach(ep => {
      if (!groupedEndpoints[ep.file]) {
        groupedEndpoints[ep.file] = [];
      }
      groupedEndpoints[ep.file].push(ep);
    });
    
    console.log('📋 API Endpoints by Module:\n');
    Object.keys(groupedEndpoints).sort().forEach(routeFile => {
      console.log(`  /${routeFile}:`);
      groupedEndpoints[routeFile].forEach(ep => {
        console.log(`    ${ep.method.padEnd(6)} ${ep.route}`);
      });
      console.log();
    });

    // ========================================================================
    // PART 2: GET ALL TABLES FROM DATABASE
    // ========================================================================
    console.log('━'.repeat(80));
    console.log('🗄️  PART 2: DATABASE SCHEMA ANALYSIS');
    console.log('━'.repeat(80) + '\n');
    
    const tablesResult = await client.query(`
      SELECT 
        table_name,
        (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
      FROM information_schema.tables t
      WHERE table_schema = 'public' 
        AND table_type = 'BASE TABLE'
      ORDER BY table_name
    `);
    
    console.log(`✓ Found ${tablesResult.rows.length} tables in database\n`);
    
    const dbTables = new Map();
    
    for (const table of tablesResult.rows) {
      const columnsResult = await client.query(`
        SELECT 
          column_name,
          data_type,
          is_nullable,
          column_default,
          character_maximum_length
        FROM information_schema.columns
        WHERE table_name = $1
        ORDER BY ordinal_position
      `, [table.table_name]);
      
      dbTables.set(table.table_name, columnsResult.rows);
    }
    
    // ========================================================================
    // PART 3: DETAILED TABLE ANALYSIS
    // ========================================================================
    console.log('━'.repeat(80));
    console.log('📊 PART 3: DETAILED TABLE SCHEMA');
    console.log('━'.repeat(80) + '\n');
    
    for (const [tableName, columns] of dbTables) {
      console.log(`📋 Table: ${tableName.toUpperCase()}`);
      console.log('   ' + '─'.repeat(76));
      
      // Get row count
      try {
        const countResult = await client.query(`SELECT COUNT(*) as count FROM "${tableName}"`);
        console.log(`   Rows: ${countResult.rows[0].count}`);
      } catch (err) {
        console.log(`   Rows: ERROR`);
      }
      
      console.log('   Columns:');
      columns.forEach(col => {
        const nullable = col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL';
        const type = col.character_maximum_length 
          ? `${col.data_type}(${col.character_maximum_length})`
          : col.data_type;
        const defaultVal = col.column_default ? ` DEFAULT ${col.column_default.substring(0, 30)}` : '';
        console.log(`     • ${col.column_name.padEnd(30)} ${type.padEnd(20)} ${nullable}${defaultVal}`);
      });
      console.log();
    }

    // ========================================================================
    // PART 4: FIND MISSING API ENDPOINTS
    // ========================================================================
    console.log('━'.repeat(80));
    console.log('⚠️  PART 4: TABLES WITHOUT API ENDPOINTS');
    console.log('━'.repeat(80) + '\n');
    
    const tablesWithoutAPI = [];
    const referencedTables = Array.from(tableReferences).map(t => t.toLowerCase());
    
    for (const [tableName] of dbTables) {
      const hasAPI = referencedTables.some(ref => 
        ref.toLowerCase() === tableName.toLowerCase() ||
        tableName.toLowerCase().includes(ref.toLowerCase()) ||
        ref.toLowerCase().includes(tableName.toLowerCase())
      );
      
      if (!hasAPI) {
        const countResult = await client.query(`SELECT COUNT(*) as count FROM "${tableName}"`);
        tablesWithoutAPI.push({
          table: tableName,
          columns: dbTables.get(tableName).length,
          rows: countResult.rows[0].count
        });
      }
    }
    
    if (tablesWithoutAPI.length > 0) {
      console.log('⚠️  Tables that may need API endpoints:\n');
      tablesWithoutAPI.forEach(t => {
        console.log(`  • ${t.table.padEnd(40)} (${t.columns} columns, ${t.rows} rows)`);
      });
    } else {
      console.log('✅ All tables have API endpoint coverage');
    }
    
    // ========================================================================
    // PART 5: CHECK FOR COMMON SCHEMA ISSUES
    // ========================================================================
    console.log('\n' + '━'.repeat(80));
    console.log('🔧 PART 5: SCHEMA VALIDATION CHECKS');
    console.log('━'.repeat(80) + '\n');
    
    const issues = [];
    
    // Check for missing primary keys
    for (const [tableName] of dbTables) {
      const pkResult = await client.query(`
        SELECT COUNT(*) as count
        FROM information_schema.table_constraints
        WHERE table_name = $1 AND constraint_type = 'PRIMARY KEY'
      `, [tableName]);
      
      if (pkResult.rows[0].count === '0') {
        issues.push(`⚠️  ${tableName}: Missing PRIMARY KEY`);
      }
    }
    
    // Check for tables without indexes
    for (const [tableName] of dbTables) {
      const idxResult = await client.query(`
        SELECT COUNT(*) as count
        FROM pg_indexes
        WHERE tablename = $1
      `, [tableName]);
      
      if (idxResult.rows[0].count === '0') {
        issues.push(`⚠️  ${tableName}: No indexes defined`);
      }
    }
    
    // Check for foreign key relationships
    console.log('🔗 Foreign Key Relationships:\n');
    const fkResult = await client.query(`
      SELECT
        tc.table_name,
        kcu.column_name,
        ccu.table_name AS foreign_table_name,
        ccu.column_name AS foreign_column_name
      FROM information_schema.table_constraints AS tc
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
      WHERE tc.constraint_type = 'FOREIGN KEY'
      ORDER BY tc.table_name, kcu.column_name
    `);
    
    const fkByTable = {};
    fkResult.rows.forEach(fk => {
      if (!fkByTable[fk.table_name]) {
        fkByTable[fk.table_name] = [];
      }
      fkByTable[fk.table_name].push(fk);
    });
    
    Object.keys(fkByTable).sort().forEach(table => {
      console.log(`  ${table}:`);
      fkByTable[table].forEach(fk => {
        console.log(`    ${fk.column_name} → ${fk.foreign_table_name}.${fk.foreign_column_name}`);
      });
    });
    
    // ========================================================================
    // PART 6: SERVICE FILE ANALYSIS
    // ========================================================================
    console.log('\n' + '━'.repeat(80));
    console.log('🛠️  PART 6: SERVICE FILES ANALYSIS');
    console.log('━'.repeat(80) + '\n');
    
    const servicesDir = path.join(__dirname, 'services');
    const serviceFiles = fs.readdirSync(servicesDir).filter(f => f.endsWith('.js'));
    
    const serviceTableRefs = new Map();
    
    for (const file of serviceFiles) {
      const content = fs.readFileSync(path.join(servicesDir, file), 'utf8');
      const serviceName = file.replace('.js', '');
      
      // Find all table references
      const matches = content.match(/FROM\s+["']?(\w+)["']?|JOIN\s+["']?(\w+)["']?|INTO\s+["']?(\w+)["']?|UPDATE\s+["']?(\w+)["']?/gi);
      
      if (matches) {
        const tables = new Set();
        matches.forEach(match => {
          const tableName = match.replace(/FROM|JOIN|INTO|UPDATE|["'`\s]/gi, '').trim();
          if (tableName && tableName.length > 0 && tableName.length < 50) {
            tables.add(tableName);
          }
        });
        
        if (tables.size > 0) {
          serviceTableRefs.set(serviceName, Array.from(tables));
        }
      }
    }
    
    console.log('Service Files and Their Table Dependencies:\n');
    Array.from(serviceTableRefs.keys()).sort().forEach(service => {
      console.log(`  ${service}Service:`);
      serviceTableRefs.get(service).forEach(table => {
        console.log(`    • ${table}`);
      });
      console.log();
    });
    
    // ========================================================================
    // PART 7: CRITICAL COLUMNS CHECK
    // ========================================================================
    console.log('━'.repeat(80));
    console.log('🎯 PART 7: CRITICAL COLUMNS VERIFICATION');
    console.log('━'.repeat(80) + '\n');
    
    const criticalChecks = [
      { table: 'user', column: 'user_id', expected: 'integer' },
      { table: 'userprofile', column: 'daily_water_target', expected: 'numeric' },
      { table: 'meal', column: 'meal_type', expected: 'character varying' },
      { table: 'meal', column: 'meal_date', expected: 'date' },
      { table: 'mealitem', column: 'weight_g', expected: 'numeric' },
      { table: 'food', column: 'food_id', expected: 'integer' },
      { table: 'nutrient', column: 'nutrient_code', expected: 'character varying' },
      { table: 'vitaminnutrient', column: 'vitamin_id', expected: 'integer' },
      { table: 'mineralnutrient', column: 'mineral_id', expected: 'integer' },
      { table: 'medicationschedule', column: 'medication_details', expected: 'jsonb' },
      { table: 'admin', column: 'is_deleted', expected: 'boolean' },
      { table: 'dish', column: 'dish_id', expected: 'integer' },
      { table: 'healthcondition', column: 'condition_id', expected: 'integer' }
    ];
    
    console.log('Checking critical columns:\n');
    for (const check of criticalChecks) {
      const result = await client.query(`
        SELECT data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = $1 AND column_name = $2
      `, [check.table, check.column]);
      
      if (result.rows.length === 0) {
        console.log(`  ❌ ${check.table}.${check.column} - MISSING`);
      } else {
        const actual = result.rows[0].data_type;
        const match = actual.includes(check.expected) || check.expected.includes(actual);
        const status = match ? '✅' : '⚠️';
        console.log(`  ${status} ${check.table}.${check.column} - ${actual} ${match ? '' : `(expected ${check.expected})`}`);
      }
    }
    
    // ========================================================================
    // FINAL SUMMARY
    // ========================================================================
    console.log('\n' + '='.repeat(80));
    console.log('📈 AUDIT SUMMARY');
    console.log('='.repeat(80) + '\n');
    
    console.log(`✓ Total Tables: ${tablesResult.rows.length}`);
    console.log(`✓ Total API Endpoints: ${apiEndpoints.length}`);
    console.log(`✓ Service Files: ${serviceFiles.length}`);
    console.log(`✓ Route Files: ${routeFiles.length}`);
    console.log(`✓ Foreign Key Relationships: ${fkResult.rows.length}`);
    console.log(`⚠️  Tables Without API: ${tablesWithoutAPI.length}`);
    console.log(`⚠️  Schema Issues Found: ${issues.length}`);
    
    if (issues.length > 0) {
      console.log('\n⚠️  Issues Detected:');
      issues.forEach(issue => console.log(`  ${issue}`));
    }
    
    console.log('\n' + '='.repeat(80) + '\n');
    
    // Save detailed report to file
    const report = {
      timestamp: new Date().toISOString(),
      database: {
        tables: tablesResult.rows.length,
        totalColumns: Array.from(dbTables.values()).reduce((sum, cols) => sum + cols.length, 0)
      },
      api: {
        endpoints: apiEndpoints.length,
        routes: routeFiles,
        services: serviceFiles.length
      },
      tablesWithoutAPI,
      issues,
      foreignKeys: fkResult.rows.length
    };
    
    fs.writeFileSync(
      path.join(__dirname, 'audit_report.json'),
      JSON.stringify(report, null, 2)
    );
    
    console.log('💾 Detailed report saved to: audit_report.json\n');
    
  } catch (error) {
    console.error('❌ Audit failed:', error.message);
    console.error(error.stack);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

comprehensiveAudit()
  .then(() => {
    console.log('✅ Comprehensive audit complete!');
    process.exit(0);
  })
  .catch((err) => {
    console.error('💥 Audit failed:', err);
    process.exit(1);
  });

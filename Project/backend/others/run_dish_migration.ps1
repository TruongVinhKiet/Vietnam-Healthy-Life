# Run Dish Management Migration
$env:PGPASSWORD="Kiet2004"

Write-Host "Running Dish Management Migration..." -ForegroundColor Green

# Use full path to psql if needed - adjust if PostgreSQL is in a different location
$psql = "C:\Program Files\PostgreSQL\17\bin\psql.exe"

if (Test-Path $psql) {
    & $psql -U postgres -d Health -f "D:\new\my_diary\backend\migrations\2025_dish_management.sql"
} else {
    # Try using psql from PATH
    psql -U postgres -d Health -f "D:\new\my_diary\backend\migrations\2025_dish_management.sql"
}

Write-Host "`nMigration complete!" -ForegroundColor Cyan

# Food Management Migration Script
# Run this in PowerShell from backend directory

Write-Host "=== Running Food Management Migration ===" -ForegroundColor Cyan

# Load environment variables
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)\s*=\s*(.+?)\s*$') {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
        }
    }
}

$dbUrl = $env:DATABASE_URL
if (-not $dbUrl) {
    Write-Host "ERROR: DATABASE_URL not found in .env" -ForegroundColor Red
    exit 1
}

Write-Host "Database: $dbUrl" -ForegroundColor Yellow

# Run migration
Write-Host "`nRunning food management enhancement migration..." -ForegroundColor Green
psql $dbUrl -f migrations/2025_enhance_food_management.sql

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✓ Migration completed successfully!" -ForegroundColor Green
} else {
    Write-Host "`n✗ Migration failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`n=== Food Management Setup Complete ===" -ForegroundColor Cyan
Write-Host "You can now:" -ForegroundColor Yellow
Write-Host "  1. Use food search API: GET /foods/search?q=chicken" -ForegroundColor White
Write-Host "  2. Get food details: GET /foods/:id" -ForegroundColor White
Write-Host "  3. Add meals with food_id and weight_g" -ForegroundColor White
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "  - Import sample foods from USDA data" -ForegroundColor White
Write-Host "  - Test meal entry dialog in Flutter app" -ForegroundColor White

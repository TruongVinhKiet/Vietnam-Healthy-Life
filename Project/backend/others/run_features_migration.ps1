# Migration Script for New Features
# Run this script to apply all new database changes

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  New Features Migration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Load environment variables
$envFile = Join-Path $PSScriptRoot ".env"
if (Test-Path $envFile) {
    Write-Host "✓ Loading environment variables..." -ForegroundColor Green
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            [System.Environment]::SetEnvironmentVariable($key, $value, [System.EnvironmentVariableTarget]::Process)
        }
    }
} else {
    Write-Host "✗ .env file not found" -ForegroundColor Red
    exit 1
}

$DATABASE_URL = $env:DATABASE_URL
if (-not $DATABASE_URL) {
    Write-Host "✗ DATABASE_URL not set in .env" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Database URL loaded" -ForegroundColor Green
Write-Host ""

# Check if migration file exists
$migrationFile = Join-Path $PSScriptRoot "migrations\2025_meal_history_and_features.sql"
if (-not (Test-Path $migrationFile)) {
    Write-Host "✗ Migration file not found: $migrationFile" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Migration file found" -ForegroundColor Green
Write-Host ""

Write-Host "Migration will add:" -ForegroundColor Yellow
Write-Host "  • Meal History tracking" -ForegroundColor White
Write-Host "  • Quick Add suggestions" -ForegroundColor White
Write-Host "  • Portion Size helper" -ForegroundColor White
Write-Host "  • Recipe Builder" -ForegroundColor White
Write-Host "  • Meal Templates" -ForegroundColor White
Write-Host "  • Photo Recognition support" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Run migration? (yes/no)"
if ($confirmation -ne "yes") {
    Write-Host "Migration cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Running migration..." -ForegroundColor Cyan

try {
    # Try to use psql if available
    $psqlPath = Get-Command psql -ErrorAction SilentlyContinue
    
    if ($psqlPath) {
        Write-Host "Using psql command..." -ForegroundColor Green
        $output = psql $DATABASE_URL -f $migrationFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "========================================" -ForegroundColor Green
            Write-Host "  ✓ Migration completed successfully!" -ForegroundColor Green
            Write-Host "========================================" -ForegroundColor Green
            Write-Host ""
            Write-Host "New features are now available:" -ForegroundColor Cyan
            Write-Host "  1. Meal History & Quick Add" -ForegroundColor White
            Write-Host "  2. Nutrition Preview" -ForegroundColor White
            Write-Host "  3. Portion Size Helper" -ForegroundColor White
            Write-Host "  4. Recipe Builder (Backend)" -ForegroundColor White
            Write-Host "  5. Meal Templates (Backend)" -ForegroundColor White
            Write-Host "  6. Photo Recognition (UI Ready)" -ForegroundColor White
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Yellow
            Write-Host "  • Restart your backend server" -ForegroundColor White
            Write-Host "  • Hot reload your Flutter app" -ForegroundColor White
            Write-Host "  • Start using the new features!" -ForegroundColor White
        } else {
            Write-Host ""
            Write-Host "✗ Migration failed" -ForegroundColor Red
            Write-Host $output -ForegroundColor Red
            exit 1
        }
    } else {
        Write-Host ""
        Write-Host "psql command not found in PATH" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Please run migration manually:" -ForegroundColor Cyan
        Write-Host "  psql `"$DATABASE_URL`" -f `"$migrationFile`"" -ForegroundColor White
        Write-Host ""
        Write-Host "Or use pgAdmin / DBeaver to execute:" -ForegroundColor Cyan
        Write-Host "  $migrationFile" -ForegroundColor White
    }
} catch {
    Write-Host ""
    Write-Host "✗ Error running migration: $_" -ForegroundColor Red
    exit 1
}

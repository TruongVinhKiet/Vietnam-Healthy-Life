# Test dashboard stats endpoint

Write-Host "Testing Dashboard Stats Endpoint..." -ForegroundColor Green

# Login
$loginBody = @{
    email = "admin@example.com"
    password = "admin123"
} | ConvertTo-Json

try {
    Write-Host "Logging in..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "http://localhost:60491/auth/admin/login" -Method POST -Body $loginBody -ContentType "application/json"
    $token = $response.token
    Write-Host "✅ Login successful!" -ForegroundColor Green
    
    # Get dashboard stats
    Write-Host "`nFetching dashboard stats..." -ForegroundColor Yellow
    $headers = @{
        Authorization = "Bearer $token"
    }
    $stats = Invoke-RestMethod -Uri "http://localhost:60491/admin/dashboard/stats" -Method GET -Headers $headers
    
    Write-Host "`n=== DASHBOARD STATISTICS ===" -ForegroundColor Cyan
    Write-Host "Total Users: $($stats.total_users)" -ForegroundColor White
    Write-Host "Total Foods: $($stats.total_foods)" -ForegroundColor White
    Write-Host "Total Nutrients: $($stats.total_nutrients)" -ForegroundColor White
    Write-Host "Today's Meals: $($stats.today_meals)" -ForegroundColor White
    Write-Host "Active Users (7 days): $($stats.active_users_7days)" -ForegroundColor White
    Write-Host "New Users This Month: $($stats.new_users_this_month)" -ForegroundColor White
    Write-Host "Total Dishes: $($stats.total_dishes)" -ForegroundColor Magenta
    Write-Host "Dish Logs: $($stats.dish_logs)" -ForegroundColor Magenta
    
    Write-Host "`n✅ Dashboard stats test completed!" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host $_.Exception.Response -ForegroundColor Red
}

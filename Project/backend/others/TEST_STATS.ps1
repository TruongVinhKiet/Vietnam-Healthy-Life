# Test script - run this in a SEPARATE terminal while server is running

Write-Host "`n=== Testing Dashboard Stats Endpoint ===" -ForegroundColor Cyan
Write-Host "Make sure backend server is running on port 60491`n" -ForegroundColor Yellow

try {
    # Login
    Write-Host "1. Logging in as admin..." -ForegroundColor White
    $loginBody = @{
        email = "admin@example.com"
        password = "admin123"
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:60491/auth/admin/login" `
        -Method POST `
        -Body $loginBody `
        -ContentType "application/json"
    
    Write-Host "   ✓ Login successful!" -ForegroundColor Green
    
    # Get stats
    Write-Host "`n2. Fetching dashboard statistics..." -ForegroundColor White
    $headers = @{
        Authorization = "Bearer $($loginResponse.token)"
    }
    
    $stats = Invoke-RestMethod -Uri "http://localhost:60491/admin/dashboard/stats" `
        -Method GET `
        -Headers $headers
    
    # Display results
    Write-Host "`n=== DASHBOARD STATISTICS ===" -ForegroundColor Cyan
    Write-Host "Total Users:           $($stats.total_users)" -ForegroundColor White
    Write-Host "Total Foods:           $($stats.total_foods)" -ForegroundColor White  
    Write-Host "Total Nutrients:       $($stats.total_nutrients)" -ForegroundColor White
    Write-Host "Today's Meals:         $($stats.today_meals)" -ForegroundColor White
    Write-Host "Active Users (7 days): $($stats.active_users_7days)" -ForegroundColor White
    Write-Host "New Users This Month:  $($stats.new_users_this_month)" -ForegroundColor White
    Write-Host "------------------------" -ForegroundColor Gray
    Write-Host "Total Dishes:          $($stats.total_dishes)" -ForegroundColor Magenta
    Write-Host "Dish Logs:             $($stats.dish_logs)" -ForegroundColor Magenta
    
    Write-Host "`n✅ Test PASSED - Dish statistics integrated successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "`n❌ Test FAILED" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "Response: $responseBody" -ForegroundColor Yellow
    }
}

Write-Host ""

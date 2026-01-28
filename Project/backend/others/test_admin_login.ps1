# Script để đăng nhập admin

$loginBody = @{
    email = "admin@example.com"  # Backend dùng field "email" nhưng thực chất là username
    password = "admin123"
} | ConvertTo-Json

Write-Host "=== Đăng nhập admin ===" -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://localhost:60491/auth/admin/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✅ Đăng nhập thành công!" -ForegroundColor Green
    Write-Host "Token: $($response.token)" -ForegroundColor Yellow
    Write-Host "Admin ID: $($response.admin.admin_id)" -ForegroundColor Cyan
    Write-Host "Username: $($response.admin.username)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Lưu token này để sử dụng cho các API khác!" -ForegroundColor Magenta
} catch {
    Write-Host "❌ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
}

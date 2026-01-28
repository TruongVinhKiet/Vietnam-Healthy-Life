# Script để test đăng ký admin

# Bước 1: Đăng ký admin (sẽ gửi mã xác thực qua email hoặc hiển thị trên console)
$registerBody = @{
    username = "admin@example.com"
    password = "admin123"
    access_code = "123456"
} | ConvertTo-Json

Write-Host "=== Đăng ký admin ===" -ForegroundColor Green
$response = Invoke-RestMethod -Uri "http://localhost:60491/auth/admin/register" -Method POST -Body $registerBody -ContentType "application/json"
Write-Host $response.message -ForegroundColor Yellow
Write-Host ""
Write-Host "Kiểm tra console của backend server để lấy mã xác thực!" -ForegroundColor Cyan
Write-Host "Sau đó chạy script test_admin_verify.ps1 với mã đó" -ForegroundColor Cyan

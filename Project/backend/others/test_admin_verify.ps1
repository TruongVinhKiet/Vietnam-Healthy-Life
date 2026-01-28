# Script để xác thực admin với mã code

# Thay YOUR_CODE bằng mã 6 chữ số từ console
$code = Read-Host "Nhập mã xác thực (6 chữ số)"

$verifyBody = @{
    username = "admin@example.com"
    code = $code
} | ConvertTo-Json

Write-Host "=== Xác thực admin ===" -ForegroundColor Green
try {
    $response = Invoke-RestMethod -Uri "http://localhost:60491/auth/admin/verify" -Method POST -Body $verifyBody -ContentType "application/json"
    Write-Host "✅ Đăng ký thành công!" -ForegroundColor Green
    Write-Host "Admin ID: $($response.admin.admin_id)" -ForegroundColor Cyan
    Write-Host "Username: $($response.admin.username)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
}

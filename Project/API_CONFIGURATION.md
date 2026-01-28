# Hướng dẫn cấu hình API cho các thiết bị khác nhau

## Tổng quan
Backend hiện đang chạy trên `0.0.0.0:60491`, cho phép kết nối từ:
- ✅ Android Emulator (máy ảo)
- ✅ iOS Simulator  
- ✅ Thiết bị thực trên cùng mạng WiFi
- ✅ Localhost

## Cấu hình API URL

Mở file: `lib/config/api_config.dart`

### 1. Cho Android Emulator (mặc định)
```dart
static const String baseUrl = 'http://10.0.2.2:60491';
```
**Giải thích:** `10.0.2.2` là địa chỉ đặc biệt trong Android Emulator trỏ đến `localhost` của máy host.

### 2. Cho iOS Simulator
```dart
static const String baseUrl = 'http://localhost:60491';
// HOẶC
static const String baseUrl = 'http://127.0.0.1:60491';
```

### 3. Cho thiết bị thực (điện thoại/tablet qua WiFi)

**Bước 1:** Tìm địa chỉ IP của máy tính

**Trên Windows:**
```powershell
ipconfig
```
Tìm dòng "IPv4 Address" (thường dạng `192.168.x.x` hoặc `10.0.x.x`)

**Trên macOS/Linux:**
```bash
ifconfig
# HOẶC
ip addr show
```

**Bước 2:** Cập nhật file config
```dart
// Ví dụ: IP máy bạn là 192.168.1.100
static const String baseUrl = 'http://192.168.1.100:60491';
```

**Lưu ý:** 
- Điện thoại và máy tính phải cùng mạng WiFi
- Tắt firewall hoặc cho phép port 60491

### 4. Tự động phát hiện platform (nâng cao)

Uncomment đoạn code này trong `api_config.dart`:

```dart
import 'dart:io';

static String get baseUrl {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:60491'; // Android emulator
  } else if (Platform.isIOS) {
    return 'http://localhost:60491'; // iOS simulator
  }
  return 'http://localhost:60491'; // Default
}
```

## Backend Configuration

Backend đã được cấu hình tự động listen trên tất cả network interfaces (`0.0.0.0`).

Xem file: `backend/others/index.js` (dòng ~592)

## Kiểm tra kết nối

### 1. Từ trình duyệt trên máy tính
```
http://localhost:60491/auth/me
```

### 2. Từ Android Emulator (trong app)
```
http://10.0.2.2:60491/auth/me
```

### 3. Từ thiết bị thực (thay YOUR_IP)
```
http://YOUR_IP:60491/auth/me
```

## Troubleshooting

### Lỗi "Connection refused"
1. ✅ Kiểm tra backend đã chạy: `npm start` trong folder `backend`
2. ✅ Kiểm tra port 60491 không bị chặn
3. ✅ Với thiết bị thực: kiểm tra cùng mạng WiFi
4. ✅ Tắt firewall tạm thời để test

### Lỗi "Network unreachable" 
1. ✅ Kiểm tra IP đúng không (dùng `ipconfig` hoặc `ifconfig`)
2. ✅ Ping từ điện thoại đến IP máy tính để test kết nối

### Hot reload không hoạt động
Sau khi đổi `baseUrl`, cần:
1. Stop app (nhấn `q` trong terminal flutter)
2. Chạy lại: `flutter run`

## Thông tin thêm

- **Port mặc định:** 60491
- **Backend file:** `backend/others/index.js`
- **Flutter config:** `lib/config/api_config.dart`
- **Environment:** `backend/.env`

## Support

Nếu gặp vấn đề, kiểm tra log:
- Backend: Terminal chạy `npm start`
- Flutter: Terminal chạy `flutter run`

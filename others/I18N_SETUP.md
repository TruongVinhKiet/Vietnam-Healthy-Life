# Hướng dẫn thiết lập và sử dụng tính năng đa ngôn ngữ (i18n)

## Tổng quan

Ứng dụng My Diary đã được tích hợp tính năng đa ngôn ngữ hỗ trợ:
- **Tiếng Việt** (mặc định)
- **Tiếng Anh**

## Cấu trúc

### 1. File translations
- `lib/l10n/app_vi.arb` - Bản dịch tiếng Việt
- `lib/l10n/app_en.arb` - Bản dịch tiếng Anh
- `l10n.yaml` - Cấu hình localization

### 2. Language Provider
- `lib/widgets/language_provider.dart` - Quản lý state ngôn ngữ và lưu preference

### 3. Generated files
Sau khi chạy `flutter gen-l10n`, Flutter sẽ tự động tạo:
- `flutter_gen/gen_l10n/app_localizations.dart` - Class chứa tất cả translations

## Cách sử dụng

### 1. Lấy translation trong widget

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Cách 1: Sử dụng AppLocalizations.of(context)
final l10n = AppLocalizations.of(context)!;
Text(l10n.settings);

// Cách 2: Sử dụng extension helper (nếu có)
import 'package:my_diary/utils/l10n_helper.dart';
Text(context.l10n.settings);
```

### 2. Thêm translation mới

1. Mở file `lib/l10n/app_en.arb` và thêm key mới:
```json
{
  "myNewKey": "My New Text"
}
```

2. Mở file `lib/l10n/app_vi.arb` và thêm bản dịch:
```json
{
  "myNewKey": "Văn bản mới của tôi"
}
```

3. Chạy lệnh để generate lại:
```bash
flutter gen-l10n
```

4. Sử dụng trong code:
```dart
Text(l10n.myNewKey);
```

### 3. Thay đổi ngôn ngữ

Người dùng có thể thay đổi ngôn ngữ trong màn hình Settings:
- Vào **Cài đặt** (Settings)
- Chọn phần **Ngôn ngữ** (Language)
- Chọn **Tiếng Việt** hoặc **Tiếng Anh**

Khi thay đổi, toàn bộ ứng dụng sẽ tự động reload và hiển thị ngôn ngữ mới.

## Các màn hình đã được cập nhật

1. ✅ Settings Screen - Có language selector
2. ✅ Main Navigation Bar - Bottom navigation labels
3. ✅ Fat View - Text hiển thị
4. ✅ Fiber View - Text hiển thị
5. ✅ Settings Screen - Interface và Seasonal UI sections

## Thêm translations cho màn hình mới

Khi tạo màn hình mới, hãy:

1. Import AppLocalizations:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

2. Thay thế hardcoded text bằng translations:
```dart
// Thay vì:
Text('Cài đặt')

// Sử dụng:
final l10n = AppLocalizations.of(context)!;
Text(l10n.settings)
```

3. Thêm các key mới vào file ARB nếu cần

## Lưu ý

- Ngôn ngữ mặc định là **Tiếng Việt**
- Preference được lưu trong SharedPreferences với key `app_language`
- Khi thay đổi ngôn ngữ, MaterialApp sẽ tự động rebuild nhờ ListenableBuilder
- Đảm bảo chạy `flutter gen-l10n` sau khi thêm/sửa translations


# Hướng dẫn sử dụng tính năng đa ngôn ngữ (i18n)

## ✅ Đã hoàn thành

Tính năng đa ngôn ngữ đã được tích hợp vào ứng dụng My Diary với:
- **Tiếng Việt** (mặc định)
- **Tiếng Anh**

## 📁 Cấu trúc file

```
my_diary/
├── l10n.yaml                          # Cấu hình localization
├── lib/
│   ├── l10n/
│   │   ├── app_vi.arb                 # Translations tiếng Việt
│   │   ├── app_en.arb                 # Translations tiếng Anh
│   │   ├── app_localizations.dart    # Generated class (tự động)
│   │   ├── app_localizations_vi.dart # Generated (tự động)
│   │   └── app_localizations_en.dart # Generated (tự động)
│   ├── widgets/
│   │   └── language_provider.dart    # Quản lý state ngôn ngữ
│   └── utils/
│       └── l10n_helper.dart          # Helper extension (optional)
```

## 🚀 Cách sử dụng

### 1. Import AppLocalizations

```dart
import 'package:my_diary/l10n/app_localizations.dart';
```

### 2. Sử dụng trong widget

```dart
// Cách 1: Sử dụng AppLocalizations.of(context)
final l10n = AppLocalizations.of(context)!;
Text(l10n.settings);

// Cách 2: Sử dụng extension helper (nếu có)
import 'package:my_diary/utils/l10n_helper.dart';
Text(context.l10n.settings);
```

### 3. Thêm translation mới

1. Mở `lib/l10n/app_en.arb` và thêm:
```json
{
  "myNewKey": "My New Text"
}
```

2. Mở `lib/l10n/app_vi.arb` và thêm:
```json
{
  "myNewKey": "Văn bản mới của tôi"
}
```

3. Chạy lệnh generate:
```bash
flutter gen-l10n
```

4. Sử dụng trong code:
```dart
Text(l10n.myNewKey);
```

## 🎯 Thay đổi ngôn ngữ

Người dùng có thể thay đổi ngôn ngữ trong màn hình **Cài đặt** (Settings):
1. Vào **Cài đặt**
2. Tìm section **Ngôn ngữ** (ở đầu danh sách)
3. Chọn **Tiếng Việt** 🇻🇳 hoặc **Tiếng Anh** 🇬🇧
4. Toàn bộ app sẽ tự động reload và hiển thị ngôn ngữ mới

## 📝 Các màn hình đã được cập nhật

✅ Settings Screen - Language selector + các section khác
✅ Main Navigation Bar - Bottom navigation labels
✅ Fat View - Text hiển thị
✅ Fiber View - Text hiển thị

## ⚠️ Lưu ý quan trọng

1. **Sau khi thêm/sửa translations**, luôn chạy:
   ```bash
   flutter gen-l10n
   ```

2. **Import path**: Sử dụng `package:my_diary/l10n/app_localizations.dart` (KHÔNG phải `flutter_gen`)

3. **Ngôn ngữ mặc định**: Tiếng Việt

4. **Lưu trữ**: Preference được lưu trong SharedPreferences với key `app_language`

5. **Tự động reload**: Khi thay đổi ngôn ngữ, MaterialApp sẽ tự động rebuild nhờ `ListenableBuilder`

## 🔧 Troubleshooting

### Lỗi: "Couldn't resolve the package 'flutter_gen'"
**Giải pháp**: Chạy `flutter gen-l10n` để generate file

### Lỗi: "The getter 'AppLocalizations' isn't defined"
**Giải pháp**: Kiểm tra import path - phải là `package:my_diary/l10n/app_localizations.dart`

### Translations không thay đổi sau khi chạy gen-l10n
**Giải pháp**: 
1. Chạy `flutter clean`
2. Chạy `flutter pub get`
3. Chạy `flutter gen-l10n`
4. Restart app

## 📚 Thêm translations cho màn hình mới

Khi tạo màn hình mới:

1. Import:
```dart
import 'package:my_diary/l10n/app_localizations.dart';
```

2. Thay thế hardcoded text:
```dart
// ❌ Không làm:
Text('Cài đặt')

// ✅ Làm:
final l10n = AppLocalizations.of(context)!;
Text(l10n.settings)
```

3. Thêm key mới vào ARB files nếu cần

## 🎨 Ví dụ sử dụng

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Text(l10n.settings),
        Text(l10n.language),
        Text(l10n.ofDailyGoal('25 g')),
      ],
    );
  }
}
```

## 📦 Dependencies

Đã được thêm vào `pubspec.yaml`:
- `flutter_localizations` (từ Flutter SDK)
- `intl: ^0.20.2`

## ✨ Tính năng

- ✅ Ngôn ngữ mặc định: Tiếng Việt
- ✅ Lưu preference tự động
- ✅ Tự động reload khi thay đổi ngôn ngữ
- ✅ UI đẹp trong Settings với dropdown và cờ quốc gia
- ✅ Hỗ trợ đầy đủ Material Design localization


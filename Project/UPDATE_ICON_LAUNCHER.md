# Hướng dẫn thay icon launcher bằng app.jpg

Để thay icon launcher Flutter gốc bằng hình ảnh `assets/app.jpg`, bạn cần tạo các file icon với các kích thước khác nhau cho Android.

## Cách 1: Sử dụng online tool (Khuyến nghị)

1. Truy cập: https://www.appicon.co/ hoặc https://icon.kitchen/
2. Upload file `assets/app.jpg`
3. Tải về bộ icon đã được tạo tự động
4. Giải nén và copy các file vào các thư mục tương ứng:
   - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
   - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
   - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
   - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
   - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

## Cách 2: Sử dụng Flutter package

Cài đặt package `flutter_launcher_icons`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

Thêm cấu hình vào `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/app.jpg"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/app.jpg"
```

Chạy lệnh:
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

## Cách 3: Sử dụng ImageMagick (Command line)

Nếu đã cài ImageMagick, chạy các lệnh sau:

```bash
# Tạo icon cho mdpi (48x48)
magick convert assets/app.jpg -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png

# Tạo icon cho hdpi (72x72)
magick convert assets/app.jpg -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png

# Tạo icon cho xhdpi (96x96)
magick convert assets/app.jpg -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png

# Tạo icon cho xxhdpi (144x144)
magick convert assets/app.jpg -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png

# Tạo icon cho xxxhdpi (192x192)
magick convert assets/app.jpg -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

## Lưu ý

- Icon nên là hình vuông (1:1 ratio)
- Nền trong suốt hoặc màu trắng sẽ hiển thị tốt hơn
- Kích thước tối thiểu: 1024x1024px cho chất lượng tốt nhất



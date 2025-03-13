# Waste Management App - Multilingual Support

## Tổng quan

Ứng dụng Waste Management hỗ trợ đa ngôn ngữ (tiếng Anh và tiếng Việt). Người dùng có thể chọn ngôn ngữ ưa thích và toàn bộ ứng dụng sẽ được hiển thị bằng ngôn ngữ đó.

## Tính năng

- **Chọn ngôn ngữ**: Người dùng có thể chọn giữa tiếng Anh và tiếng Việt
- **Tìm kiếm ngôn ngữ**: Người dùng có thể tìm kiếm ngôn ngữ theo tên
- **Lưu trữ cài đặt**: Lựa chọn ngôn ngữ được lưu trữ và duy trì giữa các phiên sử dụng
- **Thay đổi ngôn ngữ tức thì**: Toàn bộ ứng dụng được cập nhật ngay lập tức khi thay đổi ngôn ngữ

## Kiến trúc

Chức năng đa ngôn ngữ được xây dựng theo kiến trúc BLoC (Business Logic Component), giúp tách biệt logic nghiệp vụ khỏi giao diện người dùng.

### Thành phần chính

1. **Language Model**: Định nghĩa cấu trúc dữ liệu cho ngôn ngữ
2. **Language Repository**: Xử lý việc lưu trữ và truy xuất cài đặt ngôn ngữ
3. **Language BLoC**: Quản lý trạng thái và xử lý các sự kiện liên quan đến ngôn ngữ
4. **Language Events**: Các sự kiện như tải ngôn ngữ, thay đổi ngôn ngữ, tìm kiếm ngôn ngữ
5. **Language States**: Các trạng thái như đang tải, đã tải, lỗi
6. **UI Components**: Các widget hiển thị và tương tác với người dùng

## Cách sử dụng

### Chọn ngôn ngữ

1. Mở ứng dụng
2. Nhấn vào nút "Select Language" / "Chọn ngôn ngữ"
3. Chọn ngôn ngữ mong muốn từ danh sách
4. Nhấn "Continue" / "Tiếp tục" để xác nhận

### Tìm kiếm ngôn ngữ

1. Mở màn hình chọn ngôn ngữ
2. Nhập từ khóa vào ô tìm kiếm
3. Danh sách ngôn ngữ sẽ được lọc theo từ khóa

## Cấu trúc thư mục

```
lib/
  ├── blocs/
  │   └── language/
  │       ├── language_bloc.dart
  │       ├── language_event.dart
  │       ├── language_state.dart
  │       └── language_repository.dart
  ├── l10n/
  │   ├── app_en.arb
  │   └── app_vi.arb
  ├── models/
  │   └── language_model.dart
  ├── screens/
  │   └── language_selection_screen.dart
  ├── widgets/
  │   └── language/
  │       ├── language_list.dart
  │       ├── language_list_item.dart
  │       ├── language_search_field.dart
  │       └── language_continue_button.dart
  └── main.dart
```

## Mở rộng

Để thêm ngôn ngữ mới:

1. Tạo file ARB mới trong thư mục `l10n/` (ví dụ: `app_fr.arb` cho tiếng Pháp)
2. Thêm ngôn ngữ mới vào danh sách `_supportedLanguages` trong `language_bloc.dart`
3. Thêm ngôn ngữ mới vào danh sách `supportedLocales` trong `main.dart`

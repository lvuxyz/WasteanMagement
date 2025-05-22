# LVuRác - Ứng dụng Quản lý Chất thải

## Hướng dẫn cấu hình API key cho trợ lý AI

Ứng dụng LVuRác bao gồm tính năng trợ lý AI được tích hợp với OpenAI API. Để sử dụng tính năng này, bạn cần cấu hình API key của OpenAI trong file `.env`.

### Các bước thực hiện:

1. Đăng ký tài khoản tại [OpenAI](https://platform.openai.com/) nếu bạn chưa có
2. Tạo API key mới từ trang [API Keys](https://platform.openai.com/api-keys)
3. Tạo file `.env` tại thư mục gốc của dự án (nếu chưa có)
4. Thêm dòng sau vào file `.env`:

```
OPENAI_API_KEY=your_api_key_here
```

5. Thay thế `your_api_key_here` bằng API key bạn vừa tạo
6. Chạy lại ứng dụng để áp dụng thay đổi

### Chức năng Trợ lý AI

Trợ lý AI được cấu hình để chỉ trả lời các câu hỏi liên quan đến quản lý chất thải, phân loại rác, tái chế, bảo vệ môi trường và các chủ đề liên quan đến ứng dụng. Người dùng có thể truy cập trợ lý AI này thông qua:

- Nút trợ lý AI trên màn hình chính
- Mục trợ lý AI trong màn hình Trợ giúp & Hướng dẫn

**Lưu ý**: Đảm bảo giữ bí mật API key của bạn và không chia sẻ nó với người khác. API key này sẽ được lưu trữ cục bộ trên thiết bị của bạn và chỉ được sử dụng để gửi yêu cầu đến OpenAI API.

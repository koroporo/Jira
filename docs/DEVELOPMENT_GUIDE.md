# Development Guide

## 1. Thiết lập môi trường
1.  Sao chép `.env.example` thành `.env` và điền thông tin DB[cite: 1].
2.  Chạy `docker-compose up -d` để khởi động MySQL[cite: 1].
3.  Cài đặt thư viện: `pip install -r requirements.txt`[cite: 1].

## 2. Quy trình Git (Git Workflow)
*   **Main branch**: Chỉ chứa code đã chạy ổn định[cite: 1].
*   **Feature branches**: `feature/api-task`, `feature/ui-dashboard`[cite: 1].
*   **Lưu ý**: Tuyệt đối không hardcode mật khẩu vào source code[cite: 1].

## 3. Quy định về Code
*   Sử dụng Pydantic Schemas để validate dữ liệu trước khi gọi DB[cite: 1].
*   Sử dụng `logging` để ghi lại các lỗi từ Database[cite: 1].

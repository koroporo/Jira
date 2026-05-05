# Database Specification  

## 1. Tổng quan
Hệ thống sử dụng MySQL 8.0. Logic nghiệp vụ được thực thi chủ yếu qua Stored Procedures và Triggers để đảm bảo tính toàn vẹn dữ liệu.

## 2. Quy tắc phân cấp Task (Hierarchy Rules)
Dựa trên `04_triggers.sql`, hệ thống bắt buộc tuân thủ luồng:
*   **Epic**: Chỉ có thể chứa Story hoặc Bug.
*   **Story**: Chỉ có thể chứa Subtask[cite: 1].
*   **Bug/Subtask**: Là nút lá, không được phép có task con[cite: 1].

## 3. Danh sách Stored Procedures chính
| Tên Procedure | Tham số chính | Mô tả |
| :--- | :--- | :--- |
| `sp_create_task` | title, priority, parent_id... | Tạo task mới sau khi check hierarchy[cite: 1]. |
| `sp_update_task` | task_id, title, status_id... | Cập nhật thông tin task[cite: 1]. |
| `sp_delete_task` | task_id, force_delete | Xóa task (chặn nếu có task con chưa đóng)[cite: 1]. |

## 4. Bảo mật
*   Mật khẩu được băm tự động bằng Trigger `trg_hash_password_before_insert` sử dụng SHA-256 kèm salt[cite: 1].

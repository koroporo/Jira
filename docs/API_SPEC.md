# API Specification

## 1. Thông tin chung
*   **Framework**: FastAPI[cite: 1].
*   **Authentication**: Bearer Token (JWT).
*   **Quy định**: Mọi endpoint thay đổi dữ liệu (POST/PUT/DELETE) PHẢI gọi Stored Procedure[cite: 1].

## 2. Các Endpoints cốt lõi

### Task Management
*   `POST /tasks/`: Tạo task mới (Gọi `sp_create_task`)[cite: 1].
*   `PUT /tasks/{id}`: Cập nhật task (Gọi `sp_update_task`)[cite: 1].
*   `DELETE /tasks/{id}`: Xóa task (Gọi `sp_delete_task`)[cite: 1].

### Project & Board
*   `GET /projects/`: Lấy danh sách dự án hiện có[cite: 1].
*   `GET /boards/{project_id}`: Lấy danh sách board thuộc dự án[cite: 1].

## 3. Mã lỗi nghiệp vụ
*   `400`: Vi phạm logic phân cấp (ví dụ: gán Story vào Bug)[cite: 1].
*   `403`: Không có quyền thực hiện hành động (Dựa trên `RolePermission`)[cite: 1].

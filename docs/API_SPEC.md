# API Specification

## 1. Overview
*   **Framework**: FastAPI[cite: 1].
*   **Authentication**: Login returns a bearer token. The application exposes user and task endpoints under `/users` and `/tasks`.
*   **Stored procedure requirement**: All data-modifying operations (POST/PUT/DELETE) must call stored procedures.

## 2. API Endpoints

### User Authentication
*   `POST /users/login`
    * Request body: `{ "email": "user@example.com", "password": "secret" }`
    * Response: `{ "access_token": "...", "token_type": "bearer" }`
    * Authentication is generated from user credentials using password hash verification.
*   `POST /users/login-id?profile_id={id}`
    * Query parameter: `profile_id` (integer)
    * Response: user dashboard data from `sp_get_staff_dashboard`

### Task Management
*   `POST /tasks/`
    * Create a new task using `sp_create_task`.
    * Request body uses `TaskCreate` fields.
*   `GET /tasks/`
    * List tasks with optional filtering by `project_id` and `status_id`.
    * Uses `sp_get_task_list_detailed`.
*   `GET /tasks/{task_id}`
    * Retrieve a single task by ID using `sp_get_task_by_id`.
*   `PUT /tasks/{task_id}`
    * Update task fields using `sp_update_task`.
*   `DELETE /tasks/{task_id}`
    * Delete a task using `sp_delete_task`.
    * Optional query parameter: `force=true` for forced deletion.

### Reports
*   `GET /tasks/reports/milestones`
    * Returns milestone progress data from `sp_get_milestones_report`.
*   `GET /tasks/reports/performance?project_id={project_id}&min_tasks={min_tasks}`
    * Returns assignee performance metrics from `sp_report_assignee_performance`.
*   `GET /tasks/reports/staff/{profile_id}`
    * Returns staff dashboard information from `sp_get_staff_dashboard`.

## 3. Error Handling
*   `400 Bad Request`: Validation errors or invalid payloads.
*   `401 Unauthorized`: Invalid login credentials.
*   `404 Not Found`: Task or user profile not found.
*   `500 Internal Server Error`: Unexpected server errors or database failures.


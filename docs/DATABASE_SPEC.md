# Database Specification

## 1. Overview
* Database: MySQL 8.0.
* The application relies on database stored procedures, triggers, and functions to enforce business rules and maintain data integrity.
* The schema is defined in `database/01_schema.sql`, the main procedures in `database/03_procedures.sql`, triggers in `database/04_triggers.sql`, and functions in `database/05_functions.sql`.

## 2. Core Schema and Relationships
* `UserAccount` stores authentication credentials and usernames.
* `UserProfile` extends user identity details and links back to `UserAccount`.
* `Project` owns tasks and tracks aggregated task counts via triggers.
* `Task` is the central work item table. It supports parent-child relationships through `ParentTaskID` and references status, milestone, reporter, assignee, and project.
* `TaskStatus` defines allowed task states and contains `isFinishedStatus` to distinguish terminal statuses.
* `Transition` enforces valid status changes per project workflow.
* `Epic`, `Story`, `Bug`, and implicit `Subtask` types are modeled using the `Task` table plus separate type-specific tables.
* `Comment`, `Notification`, and `NotificationReceive` maintain activity and communication history tied to tasks.
* Role management tables (`Permission`, `ProjectRole`, `RolePermission`, `ProjectRoleActor`) provide a foundation for access control.

## 3. Task Hierarchy Rules
The database enforces Jira-style task hierarchy via triggers:
* `Epic` may only contain `Story` or `Bug` child tasks.
* `Story` may only contain `Subtask` child tasks.
* `Bug` may not have any child tasks.
* `Subtask` may not have any child tasks.

Violations are rejected with meaningful error messages and any partially inserted task rows are cleaned up.

## 4. Key Stored Procedures
| Procedure | Purpose | Notes |
| :--- | :--- | :--- |
| `sp_create_task` | Create a new task and insert type-specific records into `Epic`, `Story`, or `Bug` as needed. | Validates required references, title, priority, due date, and hierarchy constraints. |
| `sp_update_task` | Update task fields from a JSON payload. | Supports partial updates and validates status transitions, milestone existence, and assignee existence. |
| `sp_delete_task` | Delete a task with business deletion rules. | Prevents deletion when child tasks are active or notifications exist, unless `force_delete` is enabled. |
| `sp_get_task_list_detailed` | Retrieve detailed task listings with reporter, assignee, and project metadata. | Supports optional `project_id` and `status_id` filters. |
| `sp_get_task_by_id` | Retrieve a task by ID. |
| `sp_get_staff_dashboard` | Retrieve staff dashboard data for a profile. | Uses `num_of_overdue_task` function to calculate overdue tasks. |
| `sp_get_milestones_report` | Retrieve milestone progress data. | Uses `calculate_milestone_progress` function. |

## 5. Supporting Functions
* `num_of_overdue_task(pAssigneeID INT)` returns the number of overdue tasks for a given assignee.
* `calculate_milestone_progress(m_id INT)` returns milestone completion percentage based on task statuses.

## 6. Triggers and Derived Logic
* `trg_hash_password_before_insert` hashes `UserAccount.PasswordHash` with a static salt (`a9f3c72e1b4d8e6f`) using SHA-256 before insert.
* `trg_AfterInsertTask` increments `Project.TotalTasks` after a task is created.
* `trg_AfterDeleteTask` decrements `Project.TotalTasks` after a task is deleted.
* Task type triggers prevent duplicate type records across `Epic`, `Story`, and `Bug`.

## 7. Security and Integrity
* Password hashing is performed inside the database before inserting a user account.
* All business validations return clear errors for invalid input, missing references, and workflow violations.
* Foreign keys and cascading rules preserve referential integrity across users, tasks, projects, comments, and notifications.


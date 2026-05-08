-- ============================================================
-- sp_assert_profile_exists
--    Validates that a ProfileID exists in UserProfile.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_assert_profile_exists;
DELIMITER $$
CREATE PROCEDURE sp_assert_profile_exists(
    IN  p_ProfileID   INT
)
BEGIN
    DECLARE v_found TINYINT DEFAULT 0;
    SELECT COUNT(*) INTO v_found
    FROM   UserProfile
    WHERE  ProfileID = p_ProfileID;
 
    IF v_found = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Profile not found. Please provide a valid ProfileID for this role.';
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- 1. sp_create_task
--    Creates a new Task row after validating every constraint.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_create_task;
DELIMITER $$
CREATE PROCEDURE sp_create_task(
    IN  p_Title         VARCHAR(50),
    IN  p_Description   VARCHAR(255),
    IN  p_Priority      INT,            -- 0 = None, the higher, the more urgent
    IN  p_DueDate       TIMESTAMP,      -- NULL is allowed
    IN  p_ParentTaskID  INT,            -- NULL = top-level task
    IN  p_StatusID      INT,            -- must exist in TaskStatus
    IN  p_MilestoneID   INT,            -- NULL allowed
    IN  p_ProjectID     INT,            -- must be an existing project
    IN  p_ReporterID    INT,            -- must be an existing profile
    IN  p_AssigneeID    INT,            -- NULL allowed; if set must be an existing profile
    IN  p_TaskType      VARCHAR(10),       -- 'Epic', 'Story', 'Bug', 'Subtask'
    IN  p_TypeDetail    VARCHAR(250), -- Goal cho Epic, StoryPoint cho Story, Severity cho Bug
    OUT p_NewTaskID     INT
)
BEGIN
    DECLARE v_status_exists    TINYINT DEFAULT 0;
    DECLARE v_milestone_exists TINYINT DEFAULT 0;
    DECLARE v_project_exists   TINYINT DEFAULT 0;
 
    -- 1. Title must not be blank
    IF p_Title IS NULL OR CHAR_LENGTH(TRIM(p_Title)) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task title must not be empty.';
    END IF;
 
    -- 2. Priority range check  
    IF p_Priority IS NULL OR p_Priority < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task priority must be a non-negative integer.';
    END IF;
 
    -- 3. DueDate must not be in the past
    IF p_DueDate IS NOT NULL AND p_DueDate < NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Due date must not be set to a date in the past.';
    END IF;
 
    -- 4. Reporter must exist
    CALL sp_assert_profile_exists(p_ReporterID);
 
    -- 5. Assignee (if provided) must exist
    IF p_AssigneeID IS NOT NULL THEN
        CALL sp_assert_profile_exists(p_AssigneeID);
    END IF;
 
    -- 6. ProjectID must exist
    SELECT COUNT(*) INTO v_project_exists
    FROM   Project
    WHERE  ProjectID = p_ProjectID;

    IF v_project_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ProjectID does not exist.';
    END IF;
 
    -- 7. StatusID must exist
    IF p_StatusID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_status_exists
        FROM   TaskStatus
        WHERE  StatusID = p_StatusID;
 
        IF v_status_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'StatusID does not exist in TaskStatus.';
        END IF;
    END IF;
 
    -- 8. MilestoneID must exist (if provided)
    IF p_MilestoneID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_milestone_exists
        FROM   Milestone
        WHERE  MilestoneID = p_MilestoneID;
 
        IF v_milestone_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'MilestoneID does not exist.';
        END IF;
    END IF;
 
    -- All checks passed → INSERT
    INSERT INTO Task (
        Title, TaskDescription, TaskPriority,
        DueDate, ParentTaskID,
        StatusID, MilestoneID,
        ProjectID,
        ReporterID, AssigneeID
    ) VALUES (
        TRIM(p_Title), p_Description, COALESCE(p_Priority, 0),
        p_DueDate, p_ParentTaskID,
        p_StatusID, p_MilestoneID,
        p_ProjectID,
        p_ReporterID, p_AssigneeID
    );
    SET p_NewTaskID = LAST_INSERT_ID();
    
    IF p_TaskType = 'Epic' THEN
        INSERT INTO Epic (TaskID, Goal) VALUES (p_NewTaskID, p_TypeDetail);
    ELSEIF p_TaskType = 'Story' THEN
        INSERT INTO Story (TaskID, StoryPoint) VALUES (p_NewTaskID, CAST(p_TypeDetail AS UNSIGNED));
    ELSEIF p_TaskType = 'Bug' THEN
        INSERT INTO Bug (TaskID, Severity) VALUES (p_NewTaskID, CAST(p_TypeDetail AS UNSIGNED));
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- 2. sp_update_task
--    Updates editable fields of an existing Task.
--    Only non-NULL arguments cause a field to change
--    (pass NULL to leave a field unchanged).
-- ============================================================
DROP PROCEDURE IF EXISTS sp_update_task;
DELIMITER $$
CREATE PROCEDURE sp_update_task(
    IN p_TaskID  INT,
    IN p_data    JSON
)
BEGIN
    DECLARE v_exists           TINYINT DEFAULT 0;
    DECLARE v_status_exists    TINYINT DEFAULT 0;
    DECLARE v_milestone_exists TINYINT DEFAULT 0;
    DECLARE v_current_status   INT DEFAULT NULL;
    DECLARE v_project_id       INT DEFAULT NULL;
    DECLARE v_transition_valid TINYINT DEFAULT 0;

    -- Parse từ JSON
    DECLARE v_Title       VARCHAR(50)  DEFAULT JSON_UNQUOTE(JSON_EXTRACT(p_data, '$.title'));
    DECLARE v_Description VARCHAR(255) DEFAULT JSON_UNQUOTE(JSON_EXTRACT(p_data, '$.description'));
    DECLARE v_Priority    INT          DEFAULT JSON_EXTRACT(p_data, '$.priority');
    DECLARE v_DueDate     TIMESTAMP    DEFAULT JSON_UNQUOTE(JSON_EXTRACT(p_data, '$.due_date'));
    DECLARE v_StatusID    INT          DEFAULT JSON_EXTRACT(p_data, '$.status_id');
    DECLARE v_MilestoneID INT          DEFAULT JSON_EXTRACT(p_data, '$.milestone_id');
    DECLARE v_AssigneeID  INT          DEFAULT JSON_EXTRACT(p_data, '$.assignee_id');

    -- 1. Task must exist
    SELECT COUNT(*) INTO v_exists FROM Task WHERE TaskID = p_TaskID;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task not found.';
    END IF;

    -- 2. Title must not be blank (if being changed)
    IF v_Title IS NOT NULL AND CHAR_LENGTH(TRIM(v_Title)) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task title must not be empty.';
    END IF;

    -- 3. Priority range (if being changed)
    IF v_Priority IS NOT NULL AND v_Priority < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task priority must be a non-negative integer.';
    END IF;

    -- 4. DueDate must not be in the past (if being changed)
    IF v_DueDate IS NOT NULL AND v_DueDate != '1970-01-01 00:00:00'
       AND v_DueDate < NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Due date must not be set to a date in the past.';
    END IF;

    -- 5. StatusID transition check (if being changed)
    IF v_StatusID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_status_exists
        FROM   TaskStatus WHERE StatusID = v_StatusID;

        IF v_status_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'StatusID does not exist in TaskStatus.';
        END IF;

        SELECT t.StatusID, t.ProjectID
        INTO   v_current_status, v_project_id
        FROM   Task t
        WHERE  t.TaskID = p_TaskID;

        IF v_current_status IS NULL THEN
            SET v_transition_valid = 1;
        ELSEIF v_current_status = v_StatusID THEN
            SET v_transition_valid = 1;
        ELSEIF v_project_id IS NULL THEN
            SET v_transition_valid = 1;
        ELSE
            SELECT COUNT(*) INTO v_transition_valid
            FROM   Transition
            WHERE  FromStatus = v_current_status
              AND  StatusTo   = v_StatusID
              AND  ProjectID  = v_project_id;
        END IF;

        IF v_transition_valid = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid status transition. This move is not allowed by the project workflow.';
        END IF;
    END IF;

    -- 6. MilestoneID must exist (if being changed)
    IF v_MilestoneID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_milestone_exists
        FROM   Milestone WHERE MilestoneID = v_MilestoneID;

        IF v_milestone_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'MilestoneID does not exist.';
        END IF;
    END IF;

    -- 7. Assignee must exist (if being changed); -1 = clear assignee
    IF v_AssigneeID IS NOT NULL AND v_AssigneeID != -1 THEN
        CALL sp_assert_profile_exists(v_AssigneeID);
    END IF;

    -- All checks passed → UPDATE only changed fields
    UPDATE Task
    SET
        Title           = COALESCE(NULLIF(TRIM(v_Title), ''), Title),
        TaskDescription = COALESCE(v_Description, TaskDescription),
        TaskPriority    = COALESCE(v_Priority, TaskPriority),
        DueDate         = CASE
                            WHEN v_DueDate = '1970-01-01 00:00:00' THEN NULL
                            WHEN v_DueDate IS NOT NULL              THEN v_DueDate
                            ELSE DueDate
                          END,
        StatusID        = COALESCE(v_StatusID,    StatusID),
        MilestoneID     = COALESCE(v_MilestoneID, MilestoneID),
        AssigneeID      = CASE
                            WHEN v_AssigneeID = -1        THEN NULL
                            WHEN v_AssigneeID IS NOT NULL THEN v_AssigneeID
                            ELSE AssigneeID
                          END
    WHERE TaskID = p_TaskID;
END$$
DELIMITER ;

-- ============================================================
-- 3. sp_delete_task
--    Deletes a Task after evaluating business deletion rules.
--
--  WHEN DELETION IS ALLOWED:
--    • The task exists.
--    • The task has no open (non-closed) child tasks.
--
--  WHEN DELETION IS NOT ALLOWED:
--    • The task does not exist.
--    • The task still has at least one child task that is not
--      in a terminal status (i.e. not 'Done' or 'Cancelled').
--
--  WHY THE RESTRICTION EXISTS:
--    Deleting a parent task while children are in-progress
--    would silently orphan work that is still being tracked.
--    MySQL's ON DELETE CASCADE would remove those children
--    from the database, but their associated Comments,
--    ActivityLogs, and Notifications would cascade-delete too,
--    destroying audit history.  Forcing the caller to close
--    or reassign children first preserves data integrity and
--    gives team members visibility before records disappear.
--
--  BUSINESS PURPOSE:
--    In project management workflows an Epic or Story acts as
--    a container for ongoing work.  Removing it while child
--    tasks are active could hide unfinished work from reports
--    and velocity charts.  This guard ensures a deliberate,
--    documented close-out before deletion.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_delete_task;
DELIMITER $$
CREATE PROCEDURE sp_delete_task(
    IN p_TaskID        INT,
    IN p_ForceDelete   TINYINT
)
BEGIN
    DECLARE v_exists        TINYINT DEFAULT 0;
    DECLARE v_open_children INT     DEFAULT 0;
    DECLARE v_task_title    VARCHAR(50);

    SELECT COUNT(*) INTO v_exists
    FROM   Task
    WHERE  TaskID = p_TaskID;

    SELECT Title INTO v_task_title
    FROM   Task
    WHERE  TaskID = p_TaskID;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Deletion failed: the specified task does not exist.';
    END IF;

    SELECT COUNT(*) INTO v_open_children
    FROM   Task t
    LEFT JOIN TaskStatus ts ON ts.StatusID = t.StatusID
    WHERE  t.ParentTaskID = p_TaskID
      AND  (t.StatusID IS NULL OR ts.isFinishedStatus = FALSE);

    IF v_open_children > 0 AND p_ForceDelete = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Deletion not allowed: this task has child tasks that are still active. Close or reassign all child tasks before deleting the parent.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM   Comment c
        JOIN   Notification n    ON n.CommentID = c.CommentID
        JOIN   NotificationReceive nr ON nr.NotificationID = n.NotificationID
        WHERE  c.TaskID = p_TaskID
    ) AND p_ForceDelete = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Deletion not allowed: this task has notifications linked to its comments. Resolve or remove the linked notifications before deleting.';
    END IF;

    DELETE FROM Task WHERE TaskID = p_TaskID;
    SELECT CONCAT('Task "', v_task_title, '" (ID: ', p_TaskID, ') has been successfully deleted.') AS Result;
END$$
DELIMITER ;

-- ============================================================
-- 4. sp_get_task_list_detailed
--    Retrieves a list of tasks with detailed information for a
--    given project and/or status filter.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_get_task_list_detailed;
DELIMITER $$
CREATE PROCEDURE sp_get_task_list_detailed(
    IN p_ProjectID INT,
    IN p_StatusID INT
)
BEGIN
    SELECT 
        t.TaskID, 
        t.Title, 
        t.TaskPriority, 
        t.DueDate,
        t.CreationTime,
        t.ReporterID,
        CONCAT(r.FirstName, ' ', r.LastName) AS ReporterName,
        p.ProjectName,
        CONCAT(u.FirstName, ' ', u.LastName) AS AssigneeName,
        ts.StatusName
    FROM Task t
    INNER JOIN Project p ON t.ProjectID = p.ProjectID
    INNER JOIN TaskStatus ts ON t.StatusID = ts.StatusID
    LEFT JOIN UserProfile u ON t.AssigneeID = u.ProfileID
    LEFT JOIN UserProfile r ON t.ReporterID = r.ProfileID
    WHERE (p_ProjectID IS NULL OR t.ProjectID = p_ProjectID)
      AND (p_StatusID IS NULL OR t.StatusID = p_StatusID)
    ORDER BY t.TaskPriority DESC, t.DueDate ASC;
END$$
DELIMITER ;

-- ============================================================
-- 5. sp_report_assignee_performance
--    Generates a report of assignees with their total assigned
--    tasks and completed tasks for a given project, optionally
--    filtered by a minimum number of assigned tasks.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_report_assignee_performance;
DELIMITER $$
CREATE PROCEDURE sp_report_assignee_performance(
    IN p_ProjectID INT,
    IN p_MinTasks INT
)
BEGIN
    SELECT 
        CONCAT(u.FirstName, ' ', u.LastName) AS StaffName,
        COUNT(t.TaskID) AS TotalTasksAssigned,
        SUM(CASE WHEN ts.isFinishedStatus = 1 THEN 1 ELSE 0 END) AS CompletedTasks,
        p.ProjectName
    FROM UserProfile u
    INNER JOIN Task t ON u.ProfileID = t.AssigneeID
    INNER JOIN Project p ON t.ProjectID = p.ProjectID
    INNER JOIN TaskStatus ts ON t.StatusID = ts.StatusID
    WHERE t.ProjectID = p_ProjectID
    GROUP BY u.ProfileID, p.ProjectName
    HAVING COUNT(t.TaskID) >= COALESCE(p_MinTasks, 0)
    ORDER BY TotalTasksAssigned DESC;
END$$
DELIMITER ;

-- ============================================================
-- 6. sp_get_task_by_id
--    Retrieves detailed information for a specific task by its ID.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_get_task_by_id;
DELIMITER $$
CREATE PROCEDURE sp_get_task_by_id(IN p_TaskID INT)
BEGIN
    SELECT * FROM Task WHERE TaskID = p_TaskID;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_get_staff_dashboard;
DELIMITER $$
CREATE PROCEDURE sp_get_staff_dashboard(IN p_ProfileID INT)
BEGIN
    SELECT
        u.ProfileID,
        CONCAT(u.FirstName, ' ', u.LastName) AS FullName,
        num_of_overdue_task(u.ProfileID) AS OverdueCount,
        u.AccountStatus
    FROM UserProfile u
    WHERE u.ProfileID = p_ProfileID;
END$$
DELIMITER ;

-- ============================================================
-- 7. sp_get_milestones_report
--    Retrieves a report of all milestones with their progress and end dates.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_get_milestones_report;
DELIMITER $$
CREATE PROCEDURE sp_get_milestones_report()
BEGIN
    SELECT
        MilestoneID,
        MilestoneName,
        calculate_milestone_progress(MilestoneID) AS Progress,
        EndDate
    FROM Milestone
    ORDER BY EndDate ASC;
END$$
DELIMITER ;
-- ============================================================
-- sp_assert_profile_exists
--    Validates that a ProfileID exists in UserProfile.
-- ============================================================
DROP PROCEDURE IF EXISTS sp_assert_profile_exists;
DELIMITER $$
CREATE PROCEDURE sp_assert_profile_exists(
    IN  p_ProfileID   INT,
    IN  p_role_label  VARCHAR(30)
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
    IN  p_Priority      INT,            -- 0 = None, 1 = Low, 2 = Medium, 3 = High, 4 = Critical
    IN  p_DueDate       TIMESTAMP,      -- NULL is allowed
    IN  p_ParentTaskID  INT,            -- NULL = top-level task
    IN  p_StatusID      INT,            -- must exist in TaskStatus
    IN  p_MilestoneID   INT,            -- NULL allowed
    IN  p_ReporterID    INT,            -- must be an existing profile
    IN  p_AssigneeID    INT,            -- NULL allowed; if set must be an existing profile
    IN  p_BoardID       INT,            -- NULL allowed
    OUT p_NewTaskID     INT
)
BEGIN
    DECLARE v_status_exists    TINYINT DEFAULT 0;
    DECLARE v_milestone_exists TINYINT DEFAULT 0;
    DECLARE v_parent_type      VARCHAR(10);
    DECLARE v_board_project_id INT;
 
    -- 1. Title must not be blank
    IF p_Title IS NULL OR CHAR_LENGTH(TRIM(p_Title)) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task title must not be empty.';
    END IF;
 
    -- 2. Priority range check
    IF p_Priority IS NOT NULL AND p_Priority NOT IN (0, 1, 2, 3, 4) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task priority must be 0 (None), 1 (Low), 2 (Medium), 3 (High), or 4 (Critical).';
    END IF;
 
    -- 3. DueDate must not be in the past
    IF p_DueDate IS NOT NULL AND p_DueDate < NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Due date must not be set to a date in the past.';
    END IF;
 
    -- 4. Reporter must exist
    CALL sp_assert_profile_exists(p_ReporterID, 'Reporter');
 
    -- 5. Assignee (if provided) must exist
    IF p_AssigneeID IS NOT NULL THEN
        CALL sp_assert_profile_exists(p_AssigneeID, 'Assignee');
    END IF;
 
    -- 6. StatusID must exist
    IF p_StatusID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_status_exists
        FROM   TaskStatus
        WHERE  StatusID = p_StatusID;
 
        IF v_status_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'StatusID does not exist in TaskStatus.';
        END IF;
    END IF;
 
    -- 7. MilestoneID must exist (if provided)
    IF p_MilestoneID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_milestone_exists
        FROM   Milestone
        WHERE  MilestoneID = p_MilestoneID;
 
        IF v_milestone_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'MilestoneID does not exist.';
        END IF;
    END IF;
 
    -- 8. ParentTask hierarchy rules
    IF p_ParentTaskID IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM Task WHERE TaskID = p_ParentTaskID) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Parent task does not exist.';
        END IF;
 
        IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = p_ParentTaskID) THEN
            SET v_parent_type = 'Epic';
        ELSEIF EXISTS (SELECT 1 FROM Story WHERE TaskID = p_ParentTaskID) THEN
            SET v_parent_type = 'Story';
        ELSEIF EXISTS (SELECT 1 FROM Bug WHERE TaskID = p_ParentTaskID) THEN
            SET v_parent_type = 'Bug';
        ELSE
            SET v_parent_type = 'Subtask';
        END IF;
 
        IF v_parent_type = 'Bug' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A Bug task cannot have child tasks.';
        END IF;
        IF v_parent_type = 'Subtask' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A Subtask (plain task) cannot have child tasks.';
        END IF;
    END IF;
 
    -- 9. BoardID must exist (if provided)
    IF p_BoardID IS NOT NULL THEN
        SELECT ProjectID INTO v_board_project_id
        FROM   Board
        WHERE  BoardID = p_BoardID
        LIMIT  1;
 
        IF v_board_project_id IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'The provided BoardID does not exist.';
        END IF;
    END IF;
 
    -- All checks passed → INSERT
    INSERT INTO Task (
        Title, TaskDescription, TaskPriority,
        DueDate, ParentTaskID,
        StatusID, MilestoneID,
        ReporterID, AssigneeID, BoardID
    ) VALUES (
        TRIM(p_Title), p_Description, COALESCE(p_Priority, 0),
        p_DueDate, p_ParentTaskID,
        p_StatusID, p_MilestoneID,
        p_ReporterID, p_AssigneeID, p_BoardID
    );
    SET p_NewTaskID = LAST_INSERT_ID();
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
    IN p_TaskID       INT,
    IN p_Title        VARCHAR(50),    -- NULL = no change
    IN p_Description  VARCHAR(255),   -- NULL = no change
    IN p_Priority     INT,            -- NULL = no change
    IN p_DueDate      TIMESTAMP,      -- NULL = no change  (use '1970-01-01' to clear)
    IN p_StatusID     INT,            -- NULL = no change
    IN p_MilestoneID  INT,            -- NULL = no change
    IN p_AssigneeID   INT,            -- NULL = no change  (use 0 to clear the assignee)
    IN p_BoardID      INT             -- NULL = no change
)
BEGIN
    DECLARE v_exists           TINYINT DEFAULT 0;
    DECLARE v_status_exists    TINYINT DEFAULT 0;
    DECLARE v_milestone_exists TINYINT DEFAULT 0;
 
    -- 1. Task must exist
    SELECT COUNT(*) INTO v_exists FROM Task WHERE TaskID = p_TaskID;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task not found.';
    END IF;
 
    -- 2. Title must not be blank (if being changed)
    IF p_Title IS NOT NULL AND CHAR_LENGTH(TRIM(p_Title)) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task title must not be empty.';
    END IF;
 
    -- 3. Priority range (if being changed)
    IF p_Priority IS NOT NULL AND p_Priority NOT IN (0, 1, 2, 3, 4) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Task priority must be 0 (None), 1 (Low), 2 (Medium), 3 (High), or 4 (Critical).';
    END IF;
 
    -- 4. DueDate must not be in the past (if being changed)
    IF p_DueDate IS NOT NULL AND p_DueDate != '1970-01-01 00:00:00'
       AND p_DueDate < NOW() THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Due date must not be set to a date in the past.';
    END IF;
 
    -- 5. StatusID must exist (if being changed)
    IF p_StatusID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_status_exists
        FROM   TaskStatus
        WHERE  StatusID = p_StatusID;
 
        IF v_status_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'StatusID does not exist in TaskStatus.';
        END IF;
    END IF;
 
    -- 6. MilestoneID must exist (if being changed)
    IF p_MilestoneID IS NOT NULL THEN
        SELECT COUNT(*) INTO v_milestone_exists
        FROM   Milestone
        WHERE  MilestoneID = p_MilestoneID;
 
        IF v_milestone_exists = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'MilestoneID does not exist.';
        END IF;
    END IF;
 
    -- 7. New assignee must exist (if being changed); pass 0 to clear
    IF p_AssigneeID IS NOT NULL AND p_AssigneeID != 0 THEN
        CALL sp_assert_profile_exists(p_AssigneeID, 'Assignee');
    END IF;
 
    -- 8. BoardID must exist (if being changed)
    IF p_BoardID IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM Board WHERE BoardID = p_BoardID) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'BoardID does not exist.';
        END IF;
    END IF;
 
    -- All checks passed → UPDATE (only changed columns)
    UPDATE Task
    SET
        Title           = COALESCE(NULLIF(TRIM(p_Title), ''), Title),
        TaskDescription = COALESCE(p_Description, TaskDescription),
        TaskPriority    = COALESCE(p_Priority, TaskPriority),
        DueDate         = CASE
                            WHEN p_DueDate = '1970-01-01 00:00:00' THEN NULL
                            WHEN p_DueDate IS NOT NULL              THEN p_DueDate
                            ELSE DueDate
                          END,
        StatusID        = COALESCE(p_StatusID,    StatusID),
        MilestoneID     = COALESCE(p_MilestoneID, MilestoneID),
        AssigneeID      = CASE
                            WHEN p_AssigneeID = 0         THEN NULL
                            WHEN p_AssigneeID IS NOT NULL THEN p_AssigneeID
                            ELSE AssigneeID
                          END,
        BoardID         = COALESCE(p_BoardID, BoardID)
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
-- QUICK SMOKE-TEST CALLS
-- ============================================================
-- Test Insert: valid task
-- CALL sp_create_task('Fix login bug', 'Users cannot log in on mobile', 3,
-- '2026-12-31 00:00:00', NULL, 1, NULL, 1, 2, 1, @new_id);
-- SELECT @new_id;

-- Test Insert: blank title → should error
-- CALL sp_create_task('', NULL, 0, NULL, NULL, 1, NULL, 1, NULL, NULL, @new_id);

-- Test Insert: past due date → should error
-- CALL sp_create_task('Old task', NULL, 1, '2020-01-01 00:00:00',
-- NULL, 1, NULL, 1, NULL, NULL, @new_id);

-- Test Update: change priority and assignee
-- CALL sp_update_task(1, NULL, NULL, 4, NULL, NULL, NULL, 3, NULL);

-- Test Delete: task with active children → should error (force=0)
-- CALL sp_delete_task(1, 0);

-- Test Delete: force delete
-- CALL sp_delete_task(1,1);

-- Test Delete: Force Delete (have child task)
-- INSERT INTO Task (Title, TaskDescription, TaskPriority, StatusID, ReporterID)
-- VALUES ('Test Parent Task', 'Parent for delete test', 0, 1, 1);
-- INSERT INTO Task (Title, TaskDescription, TaskPriority, StatusID, ReporterID, ParentTaskID)
-- VALUES ('Test Child Task', 'Active child - blocks delete', 0, 1, 1, LAST_INSERT_ID());
-- CALL sp_delete_task((SELECT TaskID FROM Task WHERE Title = 'Test Parent Task'), 1);
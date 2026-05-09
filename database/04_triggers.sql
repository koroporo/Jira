-- Thanh Phu
-- DELIMITER $$
-- -- Prevent inserting into Epic if already in Story or Bug
-- DROP TRIGGER IF EXISTS prevent_duplicate_type_epic$$
-- DROP TRIGGER IF EXISTS prevent_duplicate_type_story$$
-- DROP TRIGGER IF EXISTS prevent_duplicate_type_bug$$
-- DROP PROCEDURE IF EXISTS validate_single_task_type$$

-- CREATE PROCEDURE validate_single_task_type(
--     IN p_task_id INT,
--     IN p_target_type VARCHAR(10)
-- )
-- BEGIN
--     IF p_target_type = 'Epic' THEN
--         IF EXISTS (SELECT 1 FROM Story WHERE TaskID = p_task_id) OR
--            EXISTS (SELECT 1 FROM Bug WHERE TaskID = p_task_id) THEN
--             SIGNAL SQLSTATE '45000'
--             SET MESSAGE_TEXT = 'Task already has a type (Story or Bug). Cannot also be Epic.';
--         END IF;
--     ELSEIF p_target_type = 'Story' THEN
--         IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = p_task_id) OR
--            EXISTS (SELECT 1 FROM Bug WHERE TaskID = p_task_id) THEN
--             SIGNAL SQLSTATE '45000'
--             SET MESSAGE_TEXT = 'Task already has a type (Epic or Bug). Cannot also be Story.';
--         END IF;
--     ELSEIF p_target_type = 'Bug' THEN
--         IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = p_task_id) OR
--            EXISTS (SELECT 1 FROM Story WHERE TaskID = p_task_id) THEN
--             SIGNAL SQLSTATE '45000'
--             SET MESSAGE_TEXT = 'Task already has a type (Epic or Story). Cannot also be Bug.';
--         END IF;
--     END IF;
-- END$$

-- CREATE TRIGGER prevent_duplicate_type_epic
-- BEFORE INSERT ON Epic
-- FOR EACH ROW
-- BEGIN
--     CALL validate_single_task_type(NEW.TaskID, 'Epic');
-- END$$

-- -- Prevent inserting into Story if already in Epic or Bug
-- CREATE TRIGGER prevent_duplicate_type_story
-- BEFORE INSERT ON Story
-- FOR EACH ROW
-- BEGIN
--     CALL validate_single_task_type(NEW.TaskID, 'Story');
-- END$$

-- -- Prevent inserting into Bug if already in Epic or Story
-- CREATE TRIGGER prevent_duplicate_type_bug
-- BEFORE INSERT ON Bug
-- FOR EACH ROW
-- BEGIN
--     CALL validate_single_task_type(NEW.TaskID, 'Bug');
-- END$$
-- DELIMITER ;

-- ============================================================
-- TRIGGER 1: Complex Business Constraint (Jira-Style)
-- Enforces task hierarchy rules:
-- - Epic can only contain Story or Bug (no Subtask)
-- - Story can only contain Subtask
-- - Bug cannot have child tasks (leaf node)
-- - Subtask cannot have child tasks (leaf node)
-- ============================================================

DELIMITER $$
DROP TRIGGER IF EXISTS check_task_hierarchy_jira_after_insert$$
DROP TRIGGER IF EXISTS check_task_hierarchy_jira_before_insert$$
DROP TRIGGER IF EXISTS check_task_hierarchy_jira_before_update_parent$$

CREATE TRIGGER check_task_hierarchy_jira_before_insert
BEFORE INSERT ON Task
FOR EACH ROW
BEGIN
    DECLARE parent_type VARCHAR(20);
    DECLARE parent_exists INT DEFAULT 0;
    DECLARE error_message VARCHAR(255);

    IF NEW.ParentTaskID IS NOT NULL THEN
        SELECT COUNT(*) INTO parent_exists
        FROM Task
        WHERE TaskID = NEW.ParentTaskID;

        IF parent_exists = 0 THEN
            SET error_message = CONCAT(
                'Parent task (ID=',
                NEW.ParentTaskID,
                ') does not exist'
            );
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Epic';
        ELSEIF EXISTS (SELECT 1 FROM Story WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Story';
        ELSEIF EXISTS (SELECT 1 FROM Bug WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Bug';
        ELSE
            SET parent_type = 'Subtask';
        END IF;

        -- Parent leaf types cannot have children.
        IF parent_type IN ('Bug', 'Subtask') THEN
            SET error_message = CONCAT(
                'Hierarchy violation: ',
                parent_type,
                ' (ID=',
                NEW.ParentTaskID,
                ') cannot have child tasks'
            );
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;
    END IF;
END$$

CREATE TRIGGER check_task_hierarchy_jira_before_update_parent
BEFORE UPDATE ON Task
FOR EACH ROW
BEGIN
    DECLARE parent_type VARCHAR(20);
    DECLARE child_type VARCHAR(20);
    DECLARE parent_exists INT DEFAULT 0;
    DECLARE error_message VARCHAR(255);

    IF NEW.ParentTaskID IS NOT NULL
       AND NOT (NEW.ParentTaskID <=> OLD.ParentTaskID) THEN

        SELECT COUNT(*) INTO parent_exists
        FROM Task
        WHERE TaskID = NEW.ParentTaskID;

        IF parent_exists = 0 THEN
            SET error_message = CONCAT(
                'Parent task (ID=',
                NEW.ParentTaskID,
                ') does not exist'
            );
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

        IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Epic';
        ELSEIF EXISTS (SELECT 1 FROM Story WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Story';
        ELSEIF EXISTS (SELECT 1 FROM Bug WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Bug';
        ELSE
            SET parent_type = 'Subtask';
        END IF;

        IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = NEW.TaskID) THEN
            SET child_type = 'Epic';
        ELSEIF EXISTS (SELECT 1 FROM Story WHERE TaskID = NEW.TaskID) THEN
            SET child_type = 'Story';
        ELSEIF EXISTS (SELECT 1 FROM Bug WHERE TaskID = NEW.TaskID) THEN
            SET child_type = 'Bug';
        ELSE
            SET child_type = 'Subtask';
        END IF;

        CASE parent_type
            WHEN 'Epic' THEN
                IF child_type NOT IN ('Story', 'Bug') THEN
                    SET error_message = CONCAT(
                        'Hierarchy violation: Epic (ID=',
                        NEW.ParentTaskID,
                        ') can only contain Story or Bug tasks, not ',
                        child_type
                    );
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
                END IF;
            WHEN 'Story' THEN
                IF child_type <> 'Subtask' THEN
                    SET error_message = CONCAT(
                        'Hierarchy violation: Story (ID=',
                        NEW.ParentTaskID,
                        ') can only contain Subtask, not ',
                        child_type
                    );
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
                END IF;
            WHEN 'Bug' THEN
                SET error_message = CONCAT(
                    'Hierarchy violation: Bug (ID=',
                    NEW.ParentTaskID,
                    ') cannot have any child tasks'
                );
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
            WHEN 'Subtask' THEN
                SET error_message = CONCAT(
                    'Hierarchy violation: Subtask (ID=',
                    NEW.ParentTaskID,
                    ') cannot have child tasks'
                );
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END CASE;
    END IF;
END$$
DELIMITER ;

-- ============================================================
-- TRIGGER 2: Calculate a Derived Attribute
-- Automatically hashes password with salt before storing
-- Uses SHA-256 deterministic hashing for login verification
--
-- From schema:
-- PasswordHash VARCHAR(255) NOT NULL, -- SYSTEM trigger
-- ============================================================

DELIMITER $$
-- Trigger for NEW user registration
DROP TRIGGER IF EXISTS trg_hash_password_before_insert$$
CREATE TRIGGER trg_hash_password_before_insert
BEFORE INSERT ON UserAccount
FOR EACH ROW
BEGIN
    -- Predefined static salt (fixed, never changes)
    DECLARE salt VARCHAR(16);
    SET salt = 'a9f3c72e1b4d8e6f'; 

    -- Store: salt (16 chars) + SHA256 hash (64 chars) = 80 chars total
    -- Formula: salt + SHA256(salt + raw_password)
    SET NEW.PasswordHash = SHA2(CONCAT(salt, NEW.PasswordHash), 256);

    -- 16 predefined salt chars + 64 hash chars = 80 total, fits in VARCHAR(255)
END$$
DELIMITER ;

-- ============================================================
-- TRIGGER 3: Maintain a Summary Table (TotalTasks in Project)
-- ============================================================

DELIMITER $$
DROP TRIGGER IF EXISTS trg_AfterInsertTask$$
DROP TRIGGER IF EXISTS trg_AfterDeleteTask$$
DROP TRIGGER IF EXISTS trg_AfterUpdateTaskProject$$

-- Recompute total from source-of-truth Task table after each change.
CREATE TRIGGER trg_AfterInsertTask
AFTER INSERT ON Task
FOR EACH ROW
BEGIN
    UPDATE Project 
    SET TotalTasks = (
        SELECT COUNT(*)
        FROM Task
        WHERE Task.ProjectID = NEW.ProjectID
    )
    WHERE ProjectID = NEW.ProjectID;
END$$

CREATE TRIGGER trg_AfterDeleteTask
AFTER DELETE ON Task
FOR EACH ROW
BEGIN
    UPDATE Project 
    SET TotalTasks = (
        SELECT COUNT(*)
        FROM Task
        WHERE Task.ProjectID = OLD.ProjectID
    )
    WHERE ProjectID = OLD.ProjectID;
END$$

-- If a task is moved between projects, refresh both old and new projects.
CREATE TRIGGER trg_AfterUpdateTaskProject
AFTER UPDATE ON Task
FOR EACH ROW
BEGIN
    IF NOT (NEW.ProjectID <=> OLD.ProjectID) THEN
        UPDATE Project
        SET TotalTasks = (
            SELECT COUNT(*)
            FROM Task
            WHERE Task.ProjectID = OLD.ProjectID
        )
        WHERE ProjectID = OLD.ProjectID;

        UPDATE Project
        SET TotalTasks = (
            SELECT COUNT(*)
            FROM Task
            WHERE Task.ProjectID = NEW.ProjectID
        )
        WHERE ProjectID = NEW.ProjectID;
    END IF;
END$$

-- One-time sync when this script is executed.
UPDATE Project p
SET p.TotalTasks = (
    SELECT COUNT(*)
    FROM Task t
    WHERE t.ProjectID = p.ProjectID
)$$
DELIMITER ;

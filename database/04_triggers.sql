export FLASK_APP=microblog.py

--Thanh Phu
DELIMITER $$

-- Prevent inserting into Epic if already in Story or Bug
CREATE TRIGGER prevent_duplicate_type_epic
BEFORE INSERT ON Epic
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Story WHERE TaskID = NEW.TaskID) OR
       EXISTS (SELECT 1 FROM Bug WHERE TaskID = NEW.TaskID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Task already has a type (Story or Bug). Cannot also be Epic.';
    END IF;
END$$

-- Prevent inserting into Story if already in Epic or Bug
CREATE TRIGGER prevent_duplicate_type_story
BEFORE INSERT ON Story
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = NEW.TaskID) OR
       EXISTS (SELECT 1 FROM Bug WHERE TaskID = NEW.TaskID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Task already has a type (Epic or Bug). Cannot also be Story.';
    END IF;
END$$

-- Prevent inserting into Bug if already in Epic or Story
CREATE TRIGGER prevent_duplicate_type_bug
BEFORE INSERT ON Bug
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = NEW.TaskID) OR
       EXISTS (SELECT 1 FROM Story WHERE TaskID = NEW.TaskID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Task already has a type (Epic or Story). Cannot also be Bug.';
    END IF;
END$$

DELIMITER ;





-- ============================================================
-- TRIGGER 1: Complex Business Constraint (Jira-Style)
-- Enforces task hierarchy rules WITHOUT session variables:
-- - Epic can only contain Story or Bug (no Subtask)
-- - Story can only contain Subtask
-- - Bug cannot have child tasks (leaf node)
-- - Subtask cannot have child tasks (leaf node)
-- ============================================================
 
DELIMITER $$
 
CREATE TRIGGER check_task_hierarchy_jira_after_insert
AFTER INSERT ON Task
FOR EACH ROW
BEGIN
    DECLARE parent_type VARCHAR(20);
    DECLARE child_type VARCHAR(20);
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
        
        -- Determine the PARENT task type
        IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Epic';
        ELSEIF EXISTS (SELECT 1 FROM Story WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Story';
        ELSEIF EXISTS (SELECT 1 FROM Bug WHERE TaskID = NEW.ParentTaskID) THEN
            SET parent_type = 'Bug';
        ELSE
            SET parent_type = 'Subtask';
        END IF;
        
        -- Determine the CURRENT task type
        IF EXISTS (SELECT 1 FROM Epic WHERE TaskID = NEW.TaskID) THEN
            SET child_type = 'Epic';
        ELSEIF EXISTS (SELECT 1 FROM Story WHERE TaskID = NEW.TaskID) THEN
            SET child_type = 'Story';
        ELSEIF EXISTS (SELECT 1 FROM Bug WHERE TaskID = NEW.TaskID) THEN
            SET child_type = 'Bug';
        ELSE
            SET child_type = 'Subtask';
        END IF;
        
        -- Apply hierarchy rules based on parent type
        CASE parent_type
            
            WHEN 'Epic' THEN
                IF child_type NOT IN ('Story', 'Bug') THEN
                    SET error_message = CONCAT(
                        'Hierarchy violation: Epic (ID=', 
                        NEW.ParentTaskID, 
                        ') can only contain Story or Bug tasks, not ', 
                        child_type
                    );
                    -- Clean up child tables first (foreign key order)
                    DELETE FROM Epic WHERE TaskID = NEW.TaskID;
                    DELETE FROM Story WHERE TaskID = NEW.TaskID;
                    DELETE FROM Bug WHERE TaskID = NEW.TaskID;
                    DELETE FROM Task WHERE TaskID = NEW.TaskID;
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
                END IF;
                
            WHEN 'Story' THEN
                IF child_type != 'Subtask' THEN
                    SET error_message = CONCAT(
                        'Hierarchy violation: Story (ID=', 
                        NEW.ParentTaskID, 
                        ') can only contain Subtask, not ', 
                        child_type
                    );
                    -- Clean up child tables first
                    DELETE FROM Epic WHERE TaskID = NEW.TaskID;
                    DELETE FROM Story WHERE TaskID = NEW.TaskID;
                    DELETE FROM Bug WHERE TaskID = NEW.TaskID;
                    DELETE FROM Task WHERE TaskID = NEW.TaskID;
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
                END IF;
                
            WHEN 'Bug' THEN
                SET error_message = CONCAT(
                    'Hierarchy violation: Bug (ID=', 
                    NEW.ParentTaskID, 
                    ') cannot have any child tasks'
                );
                -- Clean up child tables first
                DELETE FROM Epic WHERE TaskID = NEW.TaskID;
                DELETE FROM Story WHERE TaskID = NEW.TaskID;
                DELETE FROM Bug WHERE TaskID = NEW.TaskID;
                DELETE FROM Task WHERE TaskID = NEW.TaskID;
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
                
            WHEN 'Subtask' THEN
                SET error_message = CONCAT(
                    'Hierarchy violation: Subtask (ID=', 
                    NEW.ParentTaskID, 
                    ') cannot have child tasks. Subtask is the smallest work unit'
                );
                -- Clean up child tables first
                DELETE FROM Epic WHERE TaskID = NEW.TaskID;
                DELETE FROM Story WHERE TaskID = NEW.TaskID;
                DELETE FROM Bug WHERE TaskID = NEW.TaskID;
                DELETE FROM Task WHERE TaskID = NEW.TaskID;
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
CREATE TRIGGER trg_hash_password_before_insert
BEFORE INSERT ON UserAccount
FOR EACH ROW
BEGIN
    -- Predefined static salt (fixed, never changes)
    DECLARE salt VARCHAR(16);
    SET salt = 'a9f3c72e1b4d8e6f';  --rng

    -- Store: salt (16 chars) + SHA256 hash (64 chars) = 80 chars total
    -- Formula: salt + SHA256(salt + raw_password)
    SET NEW.PasswordHash = CONCAT(
        salt,
        SHA2(CONCAT(salt, NEW.PasswordHash), 256)
    );

    -- 16 predefined salt chars + 64 hash chars = 80 total, fits in VARCHAR(255)
END$$

DELIMITER ;

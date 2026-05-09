-- ============================================================
-- TRIGGER 1: Business Constraint (Parent-Child Integrity)
-- Enforce only generic parent-child relationship rules:
-- 1) Parent task must exist
-- 2) A task cannot be parent of itself
-- 3) Parent-child links must not create circular references
-- ============================================================

DELIMITER $$

DROP TRIGGER IF EXISTS trg_task_parent_integrity_before_insert$$
DROP TRIGGER IF EXISTS trg_task_parent_integrity_before_update$$

CREATE TRIGGER trg_task_parent_integrity_before_insert
BEFORE INSERT ON Task
FOR EACH ROW
BEGIN
    IF NEW.ParentTaskID IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM Task WHERE TaskID = NEW.ParentTaskID) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Parent-child violation: Parent task does not exist';
        END IF;

        -- If caller explicitly sets TaskID during insert, block self/cycle.
        IF NEW.ParentTaskID = NEW.TaskID THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Parent-child violation: Task cannot be parent of itself';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_task_parent_integrity_before_update
BEFORE UPDATE ON Task
FOR EACH ROW
BEGIN
    DECLARE current_parent_task_id INT;

    IF NOT (NEW.ParentTaskID <=> OLD.ParentTaskID) THEN
        IF NEW.ParentTaskID IS NOT NULL THEN
            IF NOT EXISTS (SELECT 1 FROM Task WHERE TaskID = NEW.ParentTaskID) THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Parent-child violation: Parent task does not exist';
            END IF;

            IF NEW.ParentTaskID = NEW.TaskID THEN
                SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Parent-child violation: Task cannot be parent of itself';
            END IF;

            SET current_parent_task_id = NEW.ParentTaskID;
            WHILE current_parent_task_id IS NOT NULL DO
                IF current_parent_task_id = NEW.TaskID THEN
                    SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'Parent-child violation: Circular reference detected';
                END IF;

                SELECT ParentTaskID INTO current_parent_task_id
                FROM Task
                WHERE TaskID = current_parent_task_id;
            END WHILE;
        END IF;
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- TRIGGER 2: Derived Attribute (Project.TotalTasks)
-- Keep TotalTasks synchronized with Task table changes.
-- ============================================================

DELIMITER $$

DROP TRIGGER IF EXISTS trg_project_totaltasks_after_insert_task$$
DROP TRIGGER IF EXISTS trg_project_totaltasks_after_delete_task$$
DROP TRIGGER IF EXISTS trg_project_totaltasks_after_update_task_project$$

CREATE TRIGGER trg_project_totaltasks_after_insert_task
AFTER INSERT ON Task
FOR EACH ROW
BEGIN
    UPDATE Project p
    SET p.TotalTasks = (
        SELECT COUNT(*)
        FROM Task t
        WHERE t.ProjectID = NEW.ProjectID
    )
    WHERE p.ProjectID = NEW.ProjectID;
END$$

CREATE TRIGGER trg_project_totaltasks_after_delete_task
AFTER DELETE ON Task
FOR EACH ROW
BEGIN
    UPDATE Project p
    SET p.TotalTasks = (
        SELECT COUNT(*)
        FROM Task t
        WHERE t.ProjectID = OLD.ProjectID
    )
    WHERE p.ProjectID = OLD.ProjectID;
END$$

CREATE TRIGGER trg_project_totaltasks_after_update_task_project
AFTER UPDATE ON Task
FOR EACH ROW
BEGIN
    IF NOT (NEW.ProjectID <=> OLD.ProjectID) THEN
        UPDATE Project p
        SET p.TotalTasks = (
            SELECT COUNT(*)
            FROM Task t
            WHERE t.ProjectID = OLD.ProjectID
        )
        WHERE p.ProjectID = OLD.ProjectID;

        UPDATE Project p
        SET p.TotalTasks = (
            SELECT COUNT(*)
            FROM Task t
            WHERE t.ProjectID = NEW.ProjectID
        )
        WHERE p.ProjectID = NEW.ProjectID;
    END IF;
END$$


DELIMITER ;

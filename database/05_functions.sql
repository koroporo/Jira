-- Syntax:
-- declare variables -> cursor -> loop -> fetch -> condition -> break

-- FUNCTION 1:
-- return the number of overdue tasks of an assignee
-- Input: AssigneeID INT
-- Output: INT - number of overdue tasks
-- Need to modify the status table: adding boolean is_finished
DELIMITER //
CREATE FUNCTION num_of_overdue_task (pAssigneeID INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE number_of_overdue_task INT DEFAULT 0;
    DECLARE tID INT;
    DECLARE dDate TIMESTAMP;

    DECLARE TaskCursor CURSOR FOR
        SELECT TaskID, DueDate FROM Task t INNER JOIN TaskStatus s ON t.StatusID = s.StatusID
        WHERE t.AssigneeID = pAssigneeID AND s.isFinishedStatus is False;


    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    IF pAssigneeID is NULL or pAssigneeID <= 0
    THEN
        RETURN 0;
    END IF;

    IF NOT EXISTS(SELECT 1 FROM UserProfile WHERE ProfileID = pAssigneeID)
    THEN
        RETURN 0;
    END IF;

    OPEN TaskCursor;
        label: LOOP
        FETCH TaskCursor INTO tID, dDate;
            IF done
            THEN
               LEAVE label;
            END IF;

            IF dDate < NOW()
            THEN
                SET number_of_overdue_task = number_of_overdue_task + 1;
            END IF;
        END LOOP label;
    CLOSE TaskCursor;
    RETURN number_of_overdue_task;
END //
DELIMITER ;

-- FUNCTION 2:
-- calc current progress of a milestone
-- Input: milestone_id INT
-- Output: DECIMAL(5,2) - percentage
-- Need to modify the milestone table: adding boolean is_finished
DELIMITER //
CREATE FUNCTION calculate_milestone_progress(m_id INT)
    RETURNS DECIMAL(5,2)
    DETERMINISTIC
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE total_tasks INT DEFAULT 0;
    DECLARE completed_tasks INT DEFAULT 0;
    DECLARE current_status BOOLEAN;
    DECLARE milestone_exists BOOLEAN;

    DECLARE task_cursor CURSOR FOR
        SELECT ts.isFinishedStatus
        FROM Task t INNER JOIN TaskStatus ts ON t.StatusID = ts.StatusID
        WHERE t.MilestoneID = m_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT COUNT(*) INTO milestone_exists FROM Milestone WHERE MilestoneID = m_id;
    IF milestone_exists = 0 THEN
        RETURN -1.00;
    END IF;

    OPEN task_cursor;

    label: LOOP
        FETCH task_cursor INTO current_status;
        IF done THEN
            LEAVE label;
        END IF;

        SET total_tasks = total_tasks + 1;

        IF current_status THEN
            SET completed_tasks = completed_tasks + 1;
        END IF;
    END LOOP;

CLOSE task_cursor;

IF total_tasks = 0 THEN
        RETURN 0.00;
END IF;

RETURN (completed_tasks / CAST(total_tasks AS DECIMAL)) * 100;
END //

DELIMITER ;
-- ============================================================
-- Assignment 2 – Part 1: Full Table Creation + Sample Data
-- Database Systems – Semester 2, 2025-2026
-- DBMS: MySQL
-- ============================================================
-- Create table sequence: (in order to the code can be executable)
--
-- 1. UserAccount
-- 2. UserProfile
-- 3. PhoneNumber
-- 4. Project
-- 5. Milestone
-- 6. TaskStatus
-- 8. Transition
-- 9. Task
-- 10. Story
-- 11. Bug
-- 12. Epic
-- 13. LinkedItem
-- 14. Comment
-- 15. Notification
-- 16. NotificationReceive
-- 17. Permission
-- 18. ProjectRole
-- 19. RolePermission
-- 20. ProjectRoleActor
-- 21. ActivityLog

DROP DATABASE IF EXISTS db;
CREATE DATABASE db;
USE db;

CREATE TABLE IF NOT EXISTS UserAccount (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL, -- SYSTEM trigger
    Username VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS UserProfile (
    ProfileID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    AccountStatus VARCHAR(15) NOT NULL,
    LastLoginTime TIMESTAMP, -- SYSTEM TRIGGER
    CreationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Timezone VARCHAR(50) NOT NULL,
    AvatarURL VARCHAR(255),
    UserID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES UserAccount(UserID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS PhoneNumber(
    ProfileID INT NOT NULL,
    PhoneNumber CHAR(10) NOT NULL,
    PRIMARY KEY (ProfileID, PhoneNumber),
    FOREIGN KEY (ProfileID) REFERENCES UserProfile(ProfileID)
        ON DELETE CASCADE
        ON UPDATE CASCADE -- feature
);


CREATE TABLE IF NOT EXISTS Project (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(50) NOT NULL,
    ProjectDescription VARCHAR(500),
    ProjectStatus VARCHAR(20) NOT NULL,
    CreationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FinishedTime TIMESTAMP DEFAULT NULL,
    TotalTasks INT DEFAULT 0,
    OwnerID INT, 
    FOREIGN KEY (OwnerID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE 
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Milestone(
    MilestoneID INT AUTO_INCREMENT PRIMARY KEY,
    MilestoneName VARCHAR(50),
    MilestoneGoal VARCHAR(255),
    StartDate DATE DEFAULT NULL,
    EndDate DATE DEFAULT NULL
);

CREATE TABLE IF NOT EXISTS TaskStatus (
    StatusID INT AUTO_INCREMENT PRIMARY KEY,
    StatusName VARCHAR(15) NOT NULL UNIQUE,
    isFinishedStatus BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS Transition (
    TransitionID INT AUTO_INCREMENT PRIMARY KEY,
    FromStatus INT NOT NULL,
    StatusTo INT NOT NULL,
    ProjectID INT NOT NULL,
    FOREIGN KEY(FromStatus) REFERENCES TaskStatus(StatusID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY(StatusTo) REFERENCES TaskStatus(StatusID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY(ProjectID) REFERENCES Project(ProjectID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    UNIQUE (FromStatus, StatusTo, ProjectID)
);

CREATE TABLE IF NOT EXISTS Task (
    TaskID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(50) NOT NULL,
    TaskDescription VARCHAR(500),
    TaskPriority INT DEFAULT 0,
    DueDate TIMESTAMP DEFAULT NULL,
    CreationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdateTime TIMESTAMP DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    ParentTaskID INT DEFAULT NULL,
    StatusID INT DEFAULT NULL,
    MilestoneID INT DEFAULT NULL,
    ReporterID INT,
    AssigneeID INT DEFAULT NULL,
    ProjectID INT NOT NULL,

    FOREIGN KEY(ParentTaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,  -- trigger to check the level of the task, if parent task is epic, then the child task can be story or bug, if parent task is story, then the child task can only be subtask, if parent task is bug, then it cannot have child task
    FOREIGN KEY(StatusID) REFERENCES TaskStatus(StatusID)
        ON UPDATE CASCADE ON DELETE SET NULL, -- trigger to check the status transition, only allow valid status transition based on the workflow design
    FOREIGN KEY(MilestoneID) REFERENCES Milestone(MilestoneID)
        ON UPDATE CASCADE ON DELETE SET NULL, -- trigger to check the Milestone ID, if the milestone is deleted -> milestoneID == NULL -> adding to Backlog
    FOREIGN KEY(ReporterID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE ON DELETE SET NULL, -- trigger to check the account status of the reporter, if the account is deactivated, then the reporter cannot report a task
    FOREIGN KEY(AssigneeID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE ON DELETE SET NULL, -- trigger to check the account status of the assignee, if the account is deactivated, then the assignee cannot be assigned a task
    FOREIGN KEY(ProjectID) REFERENCES Project(ProjectID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Story (
    TaskID INT,
    StoryPoint INT DEFAULT 0,

    FOREIGN KEY(TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY(TaskID)
);

CREATE TABLE IF NOT EXISTS Bug (
    TaskID INT,
    Severity INT NOT NULL,
    FOREIGN KEY(TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY(TaskID)
);

CREATE TABLE IF NOT EXISTS Epic  (
    TaskID INT,
    Goal VARCHAR(250) NOT NULL,

    FOREIGN KEY(TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY(TaskID)
);

CREATE TABLE IF NOT EXISTS LinkedItem (
    LinkedItemID INT AUTO_INCREMENT,
    TaskID INT NOT NULL,
    LinkedItem VARCHAR(2048) NOT NULL,

    FOREIGN KEY(TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY (LinkedItemID),
    UNIQUE (TaskID, LinkedItem(500)) -- hit the limit
);

CREATE TABLE IF NOT EXISTS Comment (
    CommentID INT AUTO_INCREMENT PRIMARY KEY,
    CommentContent VARCHAR(500) NOT NULL,

    CDate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    isDeleted BOOLEAN NOT NULL DEFAULT FALSE,
    DDate TIMESTAMP NULL,
    
    AuthorID INT NOT NULL,
    TaskID INT NOT NULL,

    FOREIGN KEY (AuthorID) REFERENCES UserProfile(ProfileID)  ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (TaskID) REFERENCES Task(TaskID)  ON UPDATE CASCADE ON DELETE CASCADE, -- delete a task will delete all the comments under this task;
    Check (CHAR_LENGTH(TRIM(CommentContent)) > 0),
    CHECK (
        (isDeleted = FALSE AND DDate IS NULL) OR (isDeleted = TRUE AND DDate IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS Notification (
    NotificationID INT AUTO_INCREMENT PRIMARY KEY,
    NotiDescription VARCHAR(500) NOT NULL,
    CommentID INT NOT NULL,
    TaskID INT NOT NULL,

    FOREIGN KEY (CommentID) REFERENCES Comment(CommentID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CHECK (CHAR_LENGTH(TRIM(NotiDescription)) > 0)
);

CREATE TABLE IF NOT EXISTS  NotificationReceive(
    ProfileID int NOT NULL,
    NotificationID int NOT NULL,
    SentTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ProfileID, NotificationID),
    FOREIGN KEY (ProfileID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE,
    FOREIGN KEY (NotificationID) REFERENCES Notification(NotificationID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
    -- trigger to check the account status of the user, if the account is deactivated, then the user cannot receive notification
);


CREATE TABLE IF NOT EXISTS Permission (
    PermissionID INT AUTO_INCREMENT PRIMARY KEY,
    ActionCode VARCHAR(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS ProjectRole (
    RoleID INT AUTO_INCREMENT PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL,
    Scope VARCHAR(25) NOT NULL DEFAULT 'project',
    UNIQUE (RoleName)
);

CREATE TABLE IF NOT EXISTS RolePermission(
    RoleID INT NOT NULL,
    PermissionID INT NOT NULL,

    PRIMARY KEY (RoleID, PermissionID),
    FOREIGN KEY (RoleID) REFERENCES ProjectRole(RoleID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (PermissionID) REFERENCES Permission(PermissionID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ProjectRoleActor (
    ProjectRoleActorID INT AUTO_INCREMENT PRIMARY KEY,
    RoleID INT NOT NULL,
    ProfileID INT NOT NULL,
    MembershipTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    MemberState VARCHAR(20) NOT NULL,
    
    FOREIGN KEY (RoleID) REFERENCES ProjectRole(RoleID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (ProfileID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
-- trigger to check the authority of the user when performing action, 
-- and also to log the action into activity log
-- = private + automatically generated, not allow inserting or update directly
CREATE TABLE IF NOT EXISTS ActivityLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    LogDetail VARCHAR(500) NOT NULL,
    -- e.g. "User A created a task", "User B updated a task", "User C commented on a task"  
    ActionCode VARCHAR(50) NOT NULL, -- nên sửa
    dated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    ProfileID INT NOT NULL, -- -> project role actor
    -- activity = profileID + (project role actor + project role + permission)
    -- --> result = trigger check authority + log action
    
    TaskID INT NOT NULL,
    FOREIGN KEY (ProfileID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE,
    FOREIGN KEY (TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- ============================================================
-- Assignment 2 – Part 1: Full Table Creation + Sample Data
-- Database Systems – Semester 2, 2025-2026
-- DBMS: MySQL
-- ============================================================

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
    AvatarURL VARCHAR(255), -- SYSTEM GENERATED "   cái này sao ko lưu trực tiếp luôn (blob lưu dc hình với file bao nhiêu đó) "
                                                -- answer:
                                                -- DB phình to rất nhanh
                                                -- Query chậm
                                                -- Backup nặng
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
--     CHECK (PhoneNumber REGEXP '^[0-9]{10}$') check ở tầng application
);

CREATE TABLE IF NOT EXISTS Workflow (
    WorkflowID INT AUTO_INCREMENT PRIMARY KEY,
    WorkflowName VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS TaskStatus (
    WorkflowID INT NOT NULL,
    StatusID INT AUTO_INCREMENT PRIMARY KEY,
    StatusName VARCHAR(15) NOT NULL,
    OrderIndex INT

);

CREATE TABLE IF NOT EXISTS Project (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(50) NOT NULL,
    -- ProjectCode VARCHAR(20) NOT NULL UNIQUE,
    ProjectDescription VARCHAR(255),
    ProjectStatus VARCHAR(20) NOT NULL,
    CreationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FinishedTime TIMESTAMP DEFAULT NULL,
    OwnerID INT, -- trigger
    WorkflowID INT NOT NULL,
    FOREIGN KEY (OwnerID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE -- check nha!
        ON DELETE SET NULL, -- trigger to check the organization status, if the organization is deactivated, then the project under this organization should be deactivated as well
    FOREIGN KEY (WorkflowID) REFERENCES Workflow(WorkflowID)
        ON UPDATE CASCADE
);

-- " vấn đề phát sinh: status của milestone và status của task"
CREATE TABLE IF NOT EXISTS Milestone(
    MilestoneID INT AUTO_INCREMENT PRIMARY KEY,
    MilestoneName VARCHAR(50),  -- Semantic Defaulting
    MilestoneStatus VARCHAR(15), -- Semantic Status.
    MilestoneGoal VARCHAR(255),
    StartDate DATE DEFAULT NULL,
    EndDate DATE DEFAULT NULL
);
-- ---- stopp there to check actor
CREATE TABLE IF NOT EXISTS Board (
    BoardID INT AUTO_INCREMENT PRIMARY KEY,
    BoardName VARCHAR(50) NOT NULL,
    BoardType VARCHAR(50) NOT NULL,
    CreationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CreatorID INT NOT NULL, -- Trigger
    ProjectID INT NOT NULL,

    FOREIGN KEY (CreatorID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE,
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
        ON UPDATE CASCADE

);

CREATE TABLE IF NOT EXISTS TaskStatus (
    StatusID INT AUTO_INCREMENT PRIMARY KEY,
    StatusName VARCHAR(50) NOT NULL,
    WorkflowID INT NOT NULL,
    -- STATUS CATEGORY
    -- DISPLAY ORDER
    FOREIGN KEY (WorkflowID) REFERENCES Workflow(WorkflowID) ON UPDATE CASCADE
);
CREATE TABLE IF NOT EXISTS Task (
    TaskID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(50) NOT NULL,
    TaskDescription VARCHAR(255),
    TaskPriority INT DEFAULT 0,
    DueDate TIMESTAMP DEFAULT NULL,
    CreationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdateTime TIMESTAMP DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    ParentTaskID INT DEFAULT NULL,
    StatusID INT DEFAULT NULL,
    MilestoneID INT DEFAULT NULL,
    ReporterID INT,
    AssigneeID INT DEFAULT NULL,
    BoardID INT,

    FOREIGN KEY(ParentTaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,  -- trigger to check the level of the task, if parent task is epic, then the child task can be story or bug, if parent task is story, then the child task can only be subtask, if parent task is bug, then it cannot have child task
    FOREIGN KEY(StatusID) REFERENCES TaskStatus(StatusID)
        ON UPDATE CASCADE, -- trigger to check the status transition, only allow valid status transition based on the workflow design
    FOREIGN KEY(MilestoneID) REFERENCES Milestone(MilestoneID)
        ON UPDATE CASCADE, -- trigger to check the status of the milestone, if the milestone is closed, then all the task under this milestone should be closed as well
    FOREIGN KEY(ReporterID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE, -- trigger to check the account status of the reporter, if the account is deactivated, then the reporter cannot report a task
    FOREIGN KEY(AssigneeID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE, -- trigger to check the account status of the assignee, if the account is deactivated, then the assignee cannot be assigned a task
    FOREIGN KEY(BoardID) REFERENCES Board(BoardID)
        ON UPDATE CASCADE
        ON DELETE SET NULL -- trigger to check the board status, if the board is archived, then all the task under this board should be archived as well
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
    Goal VARCHAR(255) NOT NULL,

    FOREIGN KEY(TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY(TaskID)
);

CREATE TABLE IF NOT EXISTS LinkedItem (
    LinkedItemID INT AUTO_INCREMENT,
    TaskID INT NOT NULL,
    LinkedItem VARCHAR(2048) NOT NULL, -- kich thuoc qua lon không thể dùng làm index/primary key do vượt giới hạn bytes

    FOREIGN KEY(TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    PRIMARY KEY (LinkedItemID),
    UNIQUE (TaskID, LinkedItem(255))
);

CREATE TABLE IF NOT EXISTS Comment (
    CommentID INT AUTO_INCREMENT PRIMARY KEY,
    CommentContent VARCHAR(500) NOT NULL,

    -- CreationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    AuthorID INT NOT NULL,
    TaskID INT NOT NULL,

    FOREIGN KEY (AuthorID) REFERENCES UserProfile(ProfileID) ON DELETE CASCADE,
    FOREIGN KEY (TaskID) REFERENCES Task(TaskID) ON DELETE CASCADE, -- delete a task will delete all the comments under this task;
    Check (CHAR_LENGTH(TRIM(CommentContent)) > 0)
);

CREATE TABLE IF NOT EXISTS Notification (
    NotificationID INT AUTO_INCREMENT PRIMARY KEY,
    NotiDescription VARCHAR(255) NOT NULL,
    CommentID INT,
    TaskID INT NOT NULL,

    FOREIGN KEY (CommentID) REFERENCES Comment(CommentID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
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
    -- trigger to check the account status of the user, if the account is deactivated, then the user cannot receive notification
);


CREATE TABLE IF NOT EXISTS Permission (
    PermissionID INT AUTO_INCREMENT PRIMARY KEY,
    ResourceType VARCHAR(25) NOT NULL,
    ActionCode VARCHAR(25) NOT NULL,
    Scope VARCHAR(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS ProjectRole (
    RoleID INT AUTO_INCREMENT PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL,

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
    ProjectRoleActorID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    RoleID INT NOT NULL,
    ProfileID INT NOT NULL,
    FOREIGN KEY (RoleID) REFERENCES ProjectRole(RoleID)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (ProfileID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);
-- trigger to check the authority of the user when performing action, 
-- and also to log the action into activity log
-- = private + automatically generated, not allow to insert or update directly
CREATE TABLE IF NOT EXISTS ActivityLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    LogDetail VARCHAR(500) NOT NULL,
    -- e.g. "User A created a task", "User B updated a task", "User C commented on a task"  
    ActionCode VARCHAR(50) NOT NULL, -- nên sửa
    Time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    ProfileID INT NOT NULL, -- -> projecrt role actor
    -- activy = profileID + (projectroleactor + project role + permission)
    -- --> result = trigger check authority + log action
    
    TaskID INT NOT NULL,
    FOREIGN KEY (ProfileID) REFERENCES UserProfile(ProfileID)
        ON UPDATE CASCADE,
    FOREIGN KEY (TaskID) REFERENCES Task(TaskID)
        ON UPDATE CASCADE
);
-- " organization if not doing business like jira plus or pro or businees so it must be
-- replaced by USERPROFILE because the organization is not the main entity in our system, and also it is not necessary to have organization to use our system,
-- so we can remove the organization table and replace it with user profile,
-- and also we can add a field in user profile to indicate whether the user is an admin or not, so that we can manage the permissions of the user based on this field
--
-- --> solution = use directly user profile as ORGANAZATION AND ALSO ADD A FIELD IN USER PROFILE TO INDICATE WHETHER THE USER IS AN ADMIN OR NOT, SO THAT WE CAN MANAGE THE PERMISSIONS OF THE USER BASED ON THIS FIELD
-- "
--
-- " TO DO AFTER...: Kiểm tra thứ tự tạo bảng (rất quan trọng)
-- "
-- "
-- ✅ How to verify whether a user can perform an action
-- ActivityLog itself should not be the authorization engine.
-- It is an audit trail: it records what happened after your app allowed or denied the action.
--
-- Use permissions + roles for authorization
-- Your schema already has the right pieces:
--
-- Permission stores allowed operations (ResourceType, ActionCode, Scope)
-- ProjectRole defines a role
-- RolePermission assigns permissions to roles
-- ProjectRoleActor assigns roles to users
-- Authorization flow
-- User requests an action, e.g. Edit Task, Delete Comment
-- Application checks:
-- which role(s) the user has
-- whether that role includes the needed permission
-- c
--
-- SELECT 1
-- FROM ProjectRoleActor pra
-- JOIN RolePermission rp ON rp.RoleID = pra.RoleID
-- JOIN Permission p ON p.PermissionID = rp.PermissionID
-- WHERE pra.ProfileID = ?
--   AND p.ResourceType = 'Task'
--   AND p.ActionCode = 'Edit'
-- LIMIT 1;
-- "
--
-- "epic và milestone có thể coi là 1 loại task đặc biệt, có thể dùng chung bảng Task để lưu trữ thông tin chung,
--  sau đó tạo bảng riêng để lưu trữ thông tin đặc thù của epic và milestone. nhung ma epic va
--  task khong co khong co nhieu su khac biet nen co the gop chung vao 1 bang Task, va them truong Type de phan biet giua cac loai task
--  epic khong co tac dung  chi de phan loai nen gop chung vao bang Task
--
--  one special thing of  epic is that it can have multi task but
--  CANT NOT HAVE SUBEPIC itself so we can keep base on this reason"
--
-- "added countrycode in phone number to support phone number standardization, and also added timezone in user profile to support users from different regions"
--
-- "Status Catgory removed - cannot determined conceptually,

-- and also can be determined by the workflow design, so it is redundant"

-- %Status VARCHAR(15)
-- Dùng string tự do → dễ lỗi dữ liệu (active, Active, ACTIVE…)
-- 👉 Nên dùng:
--
-- Option 1 (simple):
--
-- AccountStatus ENUM('Active','Inactive','Suspended') NOT NULL
--
-- Option 2 (chuẩn hóa):
--
-- StatusID → bảng riêng

CREATE DATABASE db;

USE db;

CREATE TABLE IF NOT EXISTS Task (
    TaskID INT AUTO_INCREMENT,
    Title VARCHAR(50) NOT NULL,
    Description VARCHAR(255),
    Priority VARCHAR(10),
    DueDate TIMESTAMP,
    CreationTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    UpdateTime TIMESTAMP DEFAULT NULL,
    ParentTaskID INT DEFAULT NULL,
    StatusID INT,
    MilestoneID INT,
    ReporterID INT,
    AssigneeID INT NOT NULL,
    BoardID INT,

    PRIMARY KEY(TaskID)
    FOREIGN KEY(ParentTaskID) REFERENCES Task(TaskID),
    FOREIGN KEY(StatusID) REFERENCES Status(StatusID),
    FOREIGN KEY(MileStoneID) REFERENCES Milestone(MilestoneID),
    FOREIGN KEY(ReporterID) REFERENCES Profile(ProfileID),
    FOREIGN KEY(AssigneeID) REFERENCES Profile(ProfileID),
    FOREIGN KEY(BoardID) REFERENCES Board(BoardID),
);

CREATE TABLE IF NOT EXISTS Story (
    TaskID INT,
    StoryPoint INT,

    FOREIGN KEY(TaskID) REFERENCES Task(TaskID),
    PRIMARY KEY(TaskID)

);

CREATE TABLE IF NOT EXISTS Bug (
    TaskID INT PRIMARY KEY,
    Severity INT NOT NULL,

    FOREIGN KEY(TaskID) REFERENCES Task(TaskId),
    PRIMARY KEY(TaskID)
);

CREATE TABLE IF NOT EXISTS Epic  (
    TaskID INT PRIMARY KEY,
    Goal VARCHAR NOT NULL

    FOREIGN KEY(TaskID) REFERENCES Task(TaskID),
    PRIMARY KEY(TaskID)
);

CREATE TABLE IF NOT EXISTS LinkedItem (
    TaskID INT,
    LinkedItem VARCHAR(2048) NOT NULL
    PRIMARY KEY (TaskID, LinkedItem)

    FOREIGN KEY(TaskID) REFERENCES Task(TaskID),
    PRIMARY KEY(TaskID)
);
""" vấn đề phát sinh: status của milestone và status của task"""
CREATE TABLE IF NOT EXISTS Milestone(
    MilestoneID INT AUTO_INCREMENT PRIMARY KEY,
    MilestoneName VARCHAR(50),
    MilestoneStatus VARCHAR(15),
    MilestoneGoal VARCHAR(255),
    StartDate DATE,
    EndDate DATE

);

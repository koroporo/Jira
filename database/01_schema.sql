CREATE DATABASE db;

USE db;

CREATE TABLE Task (
    TaskID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(50) NOT NULL,
    Description VARCHAR(255),
    Priority VARCHAR(10),
    DueDate TIMESTAMP,
    CreationTime TIMESTAMP NOT NULL,
    UpdateTime TIMESTAMP,
    ParentTaskID INT,
    StatusID INT,
    MilestoneID INT,
    ReporterID INT,
    AssigneeID INT NOT NULL,
    BoardID INT,

    FOREIGN KEY(ParentTaskID) REFERENCES Task(TaskID),
    FOREIGN KEY(StatusID) REFERENCES Status(StatusID),
    FOREIGN KEY(MileStoneID) REFERENCES Milestone(MilestoneID),
    FOREIGN KEY(ReporterID) REFERENCES Profile(ProfileID),
    FOREIGN KEY(AssigneeID) REFERENCES Profile(ProfileID),
    FOREIGN KEY(BoardID) REFERENCES Board(BoardID),





);

CREATE TABLE Story (
    TaskID INT PRIMARY KEY,
    StoryPoint INT
);

CREATE TABLE Bug (
    TaskID INT PRIMARY KEY,
    Severity INT NOT NULL
);

CREATE TABLE Epic (
    TaskID INT PRIMARY KEY,
    Goal VARCHAR NOT NULL
);

CREATE TABLE LinkedItem (
    TaskID INT,
    LinkedItem VARCHAR(2048) NOT NULL
);
""" vấn đề phát sinh: status của milestone và status của task"""
CREATE TABLE Milestone(
    MilestoneID INT AUTO_INCREMENT PRIMARY KEy,
    MilestoneName VARCHAR(50),
    MilestoneStatus VARCHAR(15),
    MilestoneGoal VARCHAR(255),
    StartDate DATE,
    EndDate DATE
);

-- ============================================================
-- Assignment 2 – Part 2: Sample Data
-- Database Systems – Semester 2, 2025-2026
-- DBMS: MySQL
-- ============================================================
-- This file includes:
-- - All user and project setup data
-- - Board records for task assignment
-- - Task records with Epic, Story, and Bug specializations
-- - Complete hierarchy: Epic → Story → Task
--              Epic → Bug → Task
-- ============================================================

-- ============================================================
-- 1. UserAccount
-- ============================================================
INSERT INTO UserAccount (Email, PasswordHash, Username)
VALUES
    ('alex.carter@example.com',
     '8d969eef6ecad3c29a3a629280e686cff8fabcb3c1c7b1f0d9f3f6d3b6d9f2f7',
     'alex.carter'),

    ('sam.lee@example.com',
     '8d969eef6ecad3c29a3a629280e686cff8fabcb3c1c7b1f0d9f3f6d3b6d9f2f7',
     'sam.lee'),

    ('taylor.nguyen@example.com',
     '8d969eef6ecad3c29a3a629280e686cff8fabcb3c1c7b1f0d9f3f6d3b6d9f2f7',
     'taylor.nguyen'),

    ('jordan.pham@example.com',
     '8d969eef6ecad3c29a3a629280e686cff8fabcb3c1c7b1f0d9f3f6d3b6d9f2f7',
     'jordan.pham'),

    ('casey.tran@example.com',
     '8d969eef6ecad3c29a3a629280e686cff8fabcb3c1c7b1f0d9f3f6d3b6d9f2f7',
     'casey.tran'),

    ('jamie.dang@example.com',
     '8d969eef6ecad3c29a3a629280e686cff8fabcb3c1c7b1f0d9f3f6d3b6d9f2f7',
     'jamie.dang');

-- ============================================================
-- 2. UserProfile
-- ============================================================
INSERT INTO UserProfile (FirstName, LastName, Email, AccountStatus, Timezone, AvatarURL, UserID)
VALUES
    ('Alex', 'Carter',
     'alex.carter@example.com',
     'Online',
     'Asia/Ho_Chi_Minh',
     'https://example.com/avatars/alex.carter.png', 1),

    ('Sam', 'Lee',
     'sam.lee@example.com',
     'Online',
     'Asia/Ho_Chi_Minh',
     'https://example.com/avatars/sam.lee.png', 2),

    ('Taylor', 'Nguyen',
     'taylor.nguyen@example.com',
     'Do Not Disturb',
     'Asia/Ho_Chi_Minh',
     'https://example.com/avatars/taylor.nguyen.png', 3),

    ('Jordan', 'Pham',
     'jordan.pham@example.com',
     'Offline',
     'Asia/Ho_Chi_Minh',
     'https://example.com/avatars/jordan.pham.png', 4),

    ('Casey', 'Tran',
     'casey.tran@example.com',
     'Idle',
     'Asia/Ho_Chi_Minh',
     'https://example.com/avatars/casey.tran.png', 5),

    ('Jamie', 'Dang',
     'jamie.dang@example.com',
     'Offline',
     'Asia/Ho_Chi_Minh',
     'https://example.com/avatars/jamie.dang.png', 6);

-- ============================================================
-- 3. Project
-- ============================================================
INSERT INTO Project (
    ProjectName,
    ProjectDescription,
    ProjectStatus,
    FinishedTime,
    OwnerID
)
VALUES
-- ProjectID 1: E-commerce Platform
(
    'E-commerce Platform',
    'Development of a scalable multi-vendor e-commerce platform targeting SME retailers in Southeast Asia. Scope includes product catalog management, payment gateway integration (Stripe, PayPal), order processing, and logistics tracking. Team consists of 1 PM, 5 backend engineers, 3 frontend engineers, and 2 QA engineers. Key stakeholders include external retail partners and internal sales team.',
    'In Progress',
    NULL,
    1
),

-- ProjectID 2: Marketing Campaign Q1
(
    'Marketing Campaign Q1',
    'Execution of Q1 digital marketing strategy focusing on brand awareness and customer acquisition. Channels include Facebook Ads, Google Ads, and email marketing. Deliverables include campaign creatives, landing pages, and performance reports. Collaboration between marketing team, design team, and external ad agency.',
    'To Do',
    '2026-03-31',
    1
),

-- ProjectID 3: HR Hiring Backend Engineers
(
    'HR - Hiring Backend Engineers',
    'Recruitment drive to hire 5 backend engineers specializing in Java and Spring Boot. Process includes job posting, CV screening, technical interviews, and onboarding. Coordination between HR team and engineering managers. Target candidates have 2-5 years experience.',
    'To Do',
    '2026-06-18',
    1
),

-- ProjectID 4: Mobile Banking App
(
    'Mobile Banking App',
    'Development of a secure mobile banking application for retail customers. Features include account management, fund transfers, bill payments, and biometric authentication. Compliance with financial regulations and security standards (PCI DSS). Team includes mobile developers, backend engineers, security specialists, and QA.',
    'To Do',
    '2026-12-15',
    1
),

-- ProjectID 5: QA Test for Project A
(
    'QA Test for Project A',
    'Comprehensive testing phase for Project A including functional testing, regression testing, and performance testing. Test cases are derived from business requirements and system specifications. QA team coordinates closely with developers to identify and resolve defects before production release.',
    'In Progress',
    '2026-05-10',
    2
);

-- ============================================================
-- 4. PhoneNumber
-- ============================================================
INSERT INTO PhoneNumber (ProfileID, PhoneNumber)
VALUES
    (1, '0900124501'),
    (2, '0900124502'),
    (3, '0900124503'),
    (4, '0900124504'),
    (5, '0900345605'),
    (6, '0900456706'),
    (1, '0900678907');

-- ============================================================
-- 5. TaskStatus
-- ============================================================
INSERT INTO TaskStatus (StatusName, isFinishedStatus)
VALUES
    ('To Do', FALSE),           -- StatusID 1
    ('In Progress', FALSE),     -- StatusID 2
    ('Review', FALSE),          -- StatusID 3
    ('Done', TRUE),             -- StatusID 4
    ('Idea', FALSE),            -- StatusID 5
    ('Planning', FALSE),        -- StatusID 6
    ('Executing', FALSE),       -- StatusID 7
    ('Code Review', FALSE),     -- StatusID 8
    ('Testing', FALSE),         -- StatusID 9
    ('To Test', FALSE),         -- StatusID 10
    ('Bug Found', FALSE),       -- StatusID 11
    ('Applied', FALSE),         -- StatusID 12
    ('Screening', FALSE),       -- StatusID 13
    ('Interview', FALSE),       -- StatusID 14
    ('Offer', FALSE),           -- StatusID 15
    ('Hired', TRUE),            -- StatusID 16
    ('Rejected', FALSE);        -- StatusID 17

-- ============================================================
-- 6. Transition
-- ============================================================
-- Project and TaskStatus records are inserted above this point.
INSERT INTO Transition (FromStatus, StatusTo, ProjectID)
VALUES
    -- Project 1: E-commerce Platform
    (1, 2, 1),   -- To Do -> In Progress
    (2, 3, 1),   -- In Progress -> Review
    (3, 4, 1),   -- Review -> Done
    (2, 1, 1),   -- In Progress -> To Do
    (3, 2, 1),   -- Review -> In Progress

    -- Project 2: Marketing Campaign Q1
    (5, 6, 2),   -- Idea -> Planning
    (6, 7, 2),   -- Planning -> Executing
    (7, 4, 2),   -- Executing -> Done
    (6, 5, 2),   -- Planning -> Idea

    -- Project 3: HR - Hiring Backend Engineers
    (12, 13, 3), -- Applied -> Screening
    (13, 14, 3), -- Screening -> Interview
    (14, 15, 3), -- Interview -> Offer
    (15, 16, 3), -- Offer -> Hired
    (13, 17, 3), -- Screening -> Rejected
    (14, 17, 3), -- Interview -> Rejected
    (15, 17, 3), -- Offer -> Rejected

    -- Project 4: Mobile Banking App
    (1, 2, 4),   -- To Do -> In Progress
    (2, 8, 4),   -- In Progress -> Code Review
    (8, 9, 4),   -- Code Review -> Testing
    (9, 4, 4),   -- Testing -> Done
    (8, 2, 4),   -- Code Review -> In Progress
    (9, 11, 4),  -- Testing -> Bug Found
    (11, 2, 4),  -- Bug Found -> In Progress

    -- Project 5: QA Test for Project AC
    (10, 9, 5),  -- To Test -> Testing
    (9, 11, 5),  -- Testing -> Bug Found
    (11, 10, 5), -- Bug Found -> To Test
    (9, 4, 5);   -- Testing -> Done

-- ============================================================
-- 7. ProjectRole
-- ============================================================
INSERT INTO ProjectRole(RoleName)
VALUES
    ('Project Manager'),
    ('Backend Developer'),
    ('Frontend Developer'),
    ('Graphic Designer'),
    ('QA Engineer'),
    ('Marketing Specialist'),
    ('HR Specialist'),
    ('Recruiter');

-- ============================================================
-- 8. Milestone
-- ============================================================
INSERT INTO Milestone
(MilestoneName, MilestoneGoal, StartDate, EndDate)
VALUES
    ('Project Kickoff Completed',
     'Team alignment session completed and project scope approved',
     '2026-02-01', '2026-02-04'),

    ('Requirements Sign-off Achieved',
     'All functional and non-functional requirements approved by stakeholders',
     '2026-02-04', '2026-02-15'),

    ('UI/UX Design Approved',
     'Final UI/UX designs reviewed and approved for development',
     '2026-05-16', '2026-05-28'),

    ('Core Modules Implemented',
     'Backend and frontend core features implemented and integrated',
     '2026-05-29', '2026-06-20'),

    ('System Testing Passed',
     'QA testing completed with all critical issues resolved',
     '2026-06-21', '2026-06-30'),

    ('Product ready to be released', 'Production-ready build finalized and approved for deployment', NULL, NULL);

-- ============================================================
-- 9. Board
-- ============================================================
INSERT INTO Board (BoardName, BoardType, CreatorID, ProjectID)
VALUES
    ('Main Board', 'Kanban', 1, 1),
    ('Marketing Board', 'Kanban', 1, 2),
    ('HR Board', 'Kanban', 1, 3),
    ('Mobile Dev Board', 'Scrum', 1, 4),
    ('QA Board', 'Kanban', 2, 5);

-- ============================================================
-- 10. Task (Base Tasks and Epic Parent Tasks)
-- ============================================================
INSERT INTO Task (
    Title, TaskDescription, TaskPriority, DueDate,
    StatusID, MilestoneID, ReporterID, AssigneeID, BoardID
)
VALUES
    -- ============================================================
    -- EPIC PARENT TASKS (3 parent tasks for Epic classification)
    -- ============================================================
    -- Epic 1:
    ('Epic: Backend Services & Payment Integration',
     'High-level initiative to develop core backend services including authentication, payment processing, and order management. This epic encompasses multiple stories related to secure API development and third-party integrations.',
     3,
     '2026-06-20',
     4, 4, 1, 3, 1),  -- TaskID 1, StatusID 4 = Done

    -- Epic 2:
    ('Epic: Frontend Development & User Interface',
     'Complete user-facing interface development including responsive design, component library, and interactive features. Encompasses all design and frontend implementation work.',
     3,
     '2026-05-28',
     2, 3, 1, 2, 1),  -- TaskID 2, StatusID 2 = In Progress

    -- Epic 3:
    ('Epic: Quality Assurance & System Testing',
     'Comprehensive testing strategy including unit tests, integration tests, and end-to-end testing. Ensures product quality before production release.',
     2,
     '2026-06-30',
     2, 5, 1, 3, 5),  -- TaskID 3, StatusID 2 = In Progress

    -- ============================================================
    -- STORY TASKS (7 child stories linked to epics via ParentTaskID)
    -- ============================================================
    -- Story 1: Set up project repository
    ('Set up project repository',
     'Initialize Git repository and basic project structure.',
     0,
     '2026-02-02',
     3, 1, 1, 2, 1),  -- TaskID 4, ParentTaskID = 1 (set via UPDATE)

    -- Story 2: Plan marketing campaign
    ('Plan marketing campaign',
     'Define campaign objectives, analyze competitors, and align with budget.',
     1,
     '2026-02-03',
     2, 1, 1, 3, 2),  -- TaskID 5, ParentTaskID = 2

    -- Story 3:
    ('Gather user requirements',
     'Interview stakeholders and collect functional and non-functional requirements.',
     3,
     '2026-02-08',
     2, 2, 1, 3, 1),  -- TaskID 6 (not part of epic)

    -- Story 4:
    ('Write SRS document',
     'Compile requirements into a Software Requirements Specification document.',
     3,
     '2026-02-14',
     2, 2, 1, 2, 1),  -- TaskID 7 (not part of epic)

    -- Story 5:
    ('Design student interface',
     'Create UI mockups in Figma for dashboard and navigation.',
     3,
     '2026-05-25',
     1, 3, 1, 2, 1),  -- TaskID 8, ParentTaskID = 2

    -- Story 6:
    ('Design high-fidelity UI',
     'Produce final UI with components and responsive layouts.',
     3,
     '2026-05-27',
     2, 3, 1, 2, 1),  -- TaskID 9, ParentTaskID = 2

    -- Story 7:
    ('Implement authentication module',
     'Develop login, registration, and JWT-based authentication.',
     3,
     '2026-06-05',
     1, 4, 1, 3, 4),  -- TaskID 10, ParentTaskID = 1

    -- Story 8:
    ('Implement payment module',
     'Develop payment feature based on technical specification.',
     3,
     '2026-06-26',
     1, 4, 3, 2, 4),  -- TaskID 11, ParentTaskID = 1

    -- Story 9:
    ('Write test cases',
     'Prepare unit and integration test cases.',
     2,
     '2026-06-24',
     1, 5, 1, 3, 5),  -- TaskID 12, ParentTaskID = 3

    -- ============================================================
    -- BUG TASK
    -- ============================================================
    -- Bug 1:
    ('[URGENT] Fix server error',
     'A new bug appeared on the server. Need to fix this ASAP.',
     3,
     '2026-06-28',
     2, 5, 1, 3, 5),  -- TaskID 13, ParentTaskID = 3

    -- ============================================================
    -- REGULAR TASK (not classified as Story/Bug/Epic)
    -- ============================================================
    --
    ('Prepare requirements specification',
     'Schedule meetings and refine requirements documentation.',
     2,
     '2026-05-15',
     2, 6, 1, 3, 1);  -- TaskID 14 (unclassified)

-- ============================================================
-- UPDATE: Link Stories to their Epic Parents
-- ============================================================
UPDATE Task SET ParentTaskID = 1 WHERE TaskID IN (4, 10, 11);     -- Link to Epic 1 (Backend)
UPDATE Task SET ParentTaskID = 2 WHERE TaskID IN (5, 8, 9);     -- Link to Epic 2 (Frontend)
UPDATE Task SET ParentTaskID = 3 WHERE TaskID IN (12, 13);       -- Link to Epic 3 (QA)

-- ============================================================
-- 11. LinkedItem
-- ============================================================
INSERT INTO LinkedItem (TaskID, LinkedItem)
VALUES
    (9, 'https://www.figma.com/design/ABC'),
    (6, 'https://drive.google.com/drive/ABC/report-template'),
    (13, 'https://github.com/ABC/A-project/event123'),
    (10, 'https://drive.google.com/drive/ABC/technical-specification-document'),
    (7, 'https://forms.google.com/customer-satisfaction-survey');

-- ============================================================
-- 12. Comment
-- ============================================================
INSERT INTO Comment (CommentContent, AuthorID, TaskID)
VALUES
    ('Repo is up, Check the linked items for detail',
     2, 4),
    ('I see. Now please update the README file so that others can catch up',
     3, 4),
    ('Could you please provide more details about the it?',
     3, 5),
    ('Interview notes uploaded. Need summarization',
     3, 6),
    ('I have checked the notes. They look really solid. Should we schedule a follow-up with the client next week?',
     2, 6),
    ('Partially done. Sections 3, 4 still need review from the dev side.',
     2, 7),
    ('What is the acceptance criteria for the search feature? It seems vague.',
     3, 7);

-- ============================================================
-- 13. Notification
-- ============================================================
INSERT INTO Notification (NotiDescription, CommentID, TaskID)
VALUES
    ('sam.lee commented on "Set up project repository".',
     1,  4),
    ('taylor.nguyen commented on "Set up project repository".',
     2,  4),
    ('taylor.nguyen commented on "Plan marketing campaign".',
     3,  5),
    ('taylor.nguyen commented on "Gather user requirements".',
     4,  6),
    ('jordan.pham commented on "Gather user requirements".',
     5,  6),
    ('jordan.pham commented on "Write SRS document".',
     6,  7),
    ('taylor.nguyen commented on "Write SRS document".',
     7,  7);

-- ============================================================
-- 14. NotificationReceive
-- ============================================================
INSERT INTO NotificationReceive (ProfileID, NotificationID, SentTime)
VALUES
    -- "Set up project repository" — reporter is ProfileID 1, assignee is ProfileID 2
    (1,  1,  '2026-02-02 08:15:00'),
    (1,  2,  '2026-02-02 09:40:00'),
    (2,  2,  '2026-02-02 09:41:00'),

    -- "Plan marketing campaign" — reporter 1, assignee 3
    (1,  3,  '2026-02-03 10:00:00'),
    (3,  3,  '2026-02-03 10:01:00'),

    -- "Gather user requirements" — reporter 1, assignee 3
    (1,  4,  '2026-02-08 14:00:00'),
    (3,  4,  '2026-02-08 14:01:00'),
    (1,  5,  '2026-02-08 15:30:00'),
    (3,  5,  '2026-02-08 15:31:00'),

    -- "Write SRS document" — reporter 1, assignee 2
    (1,  6,  '2026-02-14 09:00:00'),
    (2,  6,  '2026-02-14 09:01:00'),
    (1,  7,  '2026-02-14 11:20:00'),
    (2,  7,  '2026-02-14 11:21:00');

-- ============================================================
-- 15. Permission
-- ============================================================
INSERT INTO Permission (ResourceType, ActionCode, Scope)
VALUES
    ('Task', 'Create', 'Project'),
    ('Task', 'Edit', 'Project'),
    ('Task', 'Delete', 'Project'),
    ('Task', 'View', 'Project'),
    ('Comment', 'Create', 'Project'),
    ('Comment', 'Edit', 'Project'),
    ('Comment', 'Delete', 'Project'),
    ('Project', 'Edit', 'Project'),
    ('Board', 'Edit', 'Project');

-- ============================================================
-- 16. RolePermission
-- ============================================================
INSERT INTO RolePermission (RoleID, PermissionID)
VALUES
    (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9),  -- Project Manager has all permissions
    (2, 2), (2, 4), (2, 5), (2, 6),                                          -- Backend Developer: Edit Task, View, Create/Edit Comment
    (3, 2), (3, 4), (3, 5), (3, 6),                                          -- Frontend Developer: Edit Task, View, Create/Edit Comment
    (4, 4), (4, 5), (4, 6),                                                  -- Graphic Designer: View, Create/Edit Comment
    (5, 2), (5, 4), (5, 5), (5, 6);                                          -- QA Engineer: Edit Task, View, Create/Edit Comment

-- ============================================================
-- 17. ProjectRoleActor
-- ============================================================
INSERT INTO ProjectRoleActor (RoleID, ProfileID)
VALUES
    (1, 1), -- Alex Carter is Project Manager
    (2, 3), -- Taylor Nguyen is Backend Developer
    (3, 2), -- Sam Lee is Frontend Developer
    (4, 4), -- Jordan Pham is Graphic Designer
    (5, 5), -- Casey Tran is QA Engineer
    (6, 4); -- Jordan Pham is Marketing Specialist

-- ============================================================
-- 18. ActivityLog
-- ============================================================
INSERT INTO ActivityLog (LogDetail, ActionCode, ProfileID, TaskID)
VALUES
    ('Alex Carter created Epic: Backend Services & Payment Integration', 'CREATE_EPIC', 1, 1),
    ('Alex Carter created Epic: Frontend Development & User Interface', 'CREATE_EPIC', 1, 2),
    ('Alex Carter created task "Set up project repository" (Story: 3 points)', 'CREATE_TASK', 1, 4),
    ('Alex Carter created task "Implement authentication module" (Story: 13 points)', 'CREATE_TASK', 1, 10),
    ('Sam Lee commented on task "Set up project repository"', 'CREATE_COMMENT', 2, 4),
    ('Taylor Nguyen commented on task "Implement authentication module"', 'CREATE_COMMENT', 3, 10),
    ('Alex Carter created task "[URGENT] Fix server error" (Bug: Severity 5)', 'CREATE_BUG', 1, 13),
    ('System: Established epic-story relationship hierarchy', 'LINK_HIERARCHY', 1, 1);
-- ============================================================
-- 19. Epic
-- ============================================================
INSERT INTO Epic (TaskID, Goal)
VALUES
    (1, 'Deliver robust backend services with secure authentication and payment processing capabilities'),
    (2, 'Create modern, responsive UI that meets accessibility standards and user experience requirements'),
    (3, 'Achieve 95% test coverage and zero critical bugs before production deployment');

-- ============================================================
-- 20. Story
-- ============================================================
INSERT INTO Story (TaskID, StoryPoint)
VALUES
    (4, 3),   -- Set up project repository (3 points - infrastructure setup)
    (5, 5),   -- Plan marketing campaign (5 points - planning & analysis)
    (8, 8),   -- Design student interface (8 points - detailed UI design)
    (9, 13),  -- Design high-fidelity UI (13 points - complex visual design)
    (10, 13),  -- Implement authentication module (13 points - critical security work)
    (11, 21),  -- Implement payment module (21 points - high complexity integration)
    (12, 8);   -- Write test cases (8 points - comprehensive test coverage)

-- ============================================================
-- 21. Bug
-- ============================================================
INSERT INTO Bug (TaskID, Severity)
VALUES
    (13, 5);  -- [URGENT] Fix server error (5 = Critical/Blocker severity)

-- ============================================================
-- END OF DATA INSERTION
-- ============================================================

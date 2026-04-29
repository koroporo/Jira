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

INSERT INTO UserProfile (FirstName, LastName, Email, AccountStatus, Timezone, AvatarURL, UserID)
VALUES
    ('Alex', 'Carter',
     'alex.carter@example.com',
     'Online',          
     'Asia/Ho_Chi_Minh', 
     'https://jira.com/avatars/alex.carter.png', 1),

    ('Sam', 'Lee',
     'sam.lee@example.com',
     'Online',
     'Asia/Ho_Chi_Minh',
     'https://jira.com/avatars/sam.lee.png', 2),

    ('Taylor', 'Nguyen',     
     'taylor.nguyen@example.com',
     'Do Not Disturb',
     'Asia/Ho_Chi_Minh',
     'https://jira.com/avatars/taylor.nguyen.png', 3),

    ('Jordan', 'Pham',
     'jordan.pham@example.com',
     'Offline',
     'Asia/Ho_Chi_Minh',  
     'https://jira.com/avatars/jordan.pham.png', 4),

    ('Casey', 'Tran',
     'casey.tran@example.com',
     'Idle',
     'Asia/Ho_Chi_Minh',
     'https://jira.com/avatars/casey.tran.png', 5),

    ('Jamie', 'Dang',
     'jamie.dang@example.com',
     'Offline',
     'Asia/Ho_Chi_Minh',
     'https://jira.com/avatars/jamie.dang.png', 6);

INSERT INTO PhoneNumber (ProfileID, PhoneNumber) 
VALUES
    (1, '0000000001'),
    (2, '0000000002'),
    (3, '0000000003'),
    (4, '0000000004'),
    (5, '0000000005'),
    (6, '0000000006'),
    (1, '0000000007');
    
INSERT INTO Milestone(MilestoneName, MilestoneStatus, MilestoneGoal, StartDate, EndDate)
VALUES ('Project Kickoff',
        'Completed',
        'Align team on scope, timeline and initial requirements',
        2026-02-01,2026-02-04),

       ('Requirements phase',
        'Completed',
        'Requirements elicitation'
        2026-02-04, 2026-02-15),

       ('UI/UX design',
        'In Progress',
        'Create and iterate UI designs for user flows',
        2026-05-16, 2026-05-28),

       ('Core development',
        'Not Started',
        'Implement features and deploy product',
        2026-05-29, 2026-06-20),

       ('Quality Assurance',
        'Not Started',
        'Perform quality control and prepare for release',
        2026-06-21, 2026-06-30),

       ('Others',
        'In Progress',
        NULL,NULL, NULL);

INSERT INTO Task (
    Title, Description, Priority, DueDate,
    StatusID, MilestoneID, ReporterID, AssigneeID, BoardID
)
VALUES
    ('Set up project repository',
     'Initialize Git repository and basic project structure.',
     'Medium',
     '2026-02-02',
     3, 1, 1, 2, 1),

    ('Plan marketing campaign',
     'Define campaign objectives, analyze competitors, and align with budget.',
     'Low',
     '2026-02-03',
     2, 1, 1, 3, 1),

    ('Gather user requirements',
     'Interview stakeholders and collect functional and non-functional requirements.',
     'High',
     '2026-02-08',
     2, 2, 1, 3, 1),

    ('Write SRS document',
     'Compile requirements into a Software Requirements Specification document.',
     'High',
     '2026-02-14',
     2, 2, 1, 2, 1),

    ('Design student interface',
     'Create UI mockups in Figma for dashboard and navigation.',
     'High',
     '2026-05-25',
     1, 3, 1, 2, 1),

    ('Design high-fidelity UI',
     'Produce final UI with components and responsive layouts.',
     'High',
     '2026-05-27',
     2, 3, 1, 2, 1),

    ('Implement authentication module',
     'Develop login, registration, and JWT-based authentication.',
     'High',
     '2026-06-05',
     1, 4, 1, 3, 1),

    ('Implement payment module',
     'Develop payment feature based on technical specification.',
     'High',
     '2026-06-26',
     1, 4, 3, 2, 1),

    ('Write test cases',
     'Prepare unit and integration test cases.',
     'Medium',
     '2026-06-24',
     1, 5, 1, 3, 1),

    ('[URGENT] Fix server error',
     'A new bug appeared on the server. Need to fix this ASAP.',
     'High',
     '2026-06-28',
     2, 5, 1, 3, 1),

    ('Prepare requirements specification',
     'Schedule meetings and refine requirements documentation.',
     'Medium',
     '2026-05-15',
     2, 6, 1, 3, 1);
INSERT INTO LinkedItem (TaskID, LinkedItem)
VALUES
    (2, 'https://www.figma.com/design/ABC'),
    (3, 'https://drive.google.com/drive/ABC/report-template'),
    (5, 'https://github.com/ABC/A-project/event123'),
    (1, 'https://drive.google.com/drive/ABC/technical-specification-document'),
    (4, 'https://forms.google.com/customer-satisfaction-survey');

-- ============================================================
-- 15. Comment
-- ============================================================
INSERT INTO Comment (CommentContent, AuthorID, TaskID)
VALUES
    ('Repo is up, branch naming convention doc is in the wiki.',
     2, 1),

    ('Initial folder structure pushed. README needs more detail.',
     3, 1),

    ('Competitor analysis added, Main takeaway — Launch before Q2.',
    3, 2),

    ('Interview notes uploaded. Summarised into 12 functional and 4 non-functional requirements.',
     3, 3),
    ('Checked the notes, looks solid. Should we schedule a follow-up with the client next week?',
     2, 3),

    ('SRS draft done. Sections 3, 4 still need review from the dev side.',
     2, 4),
    ('Left comments on section 3. The acceptance criteria for the search feature is too vague.',
     3, 4),

    ('First set of frames is up on Figma. Focused on the dashboard and sidebar nav for now.',
     2, 5),

    ('High-fi is ready for handoff. Exported assets are in the shared Drive folder.',
     2, 6),
    ('Looks great overall. Minor spacing issue on the mobile breakpoint — flagged in Figma.',
     3, 6),

    ('PR is up for review. JWT refresh logic is in AuthService, unit tests included.',
     3, 7),
    ('Left 2 review comments. The token expiry config should come from env, not hardcoded.',
     2, 7),

    ('Sandbox is returning 500 on the /confirm endpoint. Checked logs — looks like a missing header.',
     2,  8),
    ('Reproduced it. The gateway expects Content-Type: application/json on every request. Fixing now.',
     3,  8),

    ('Test cases for modules 1–3 are done. Module 4 needs the final API spec before I can finish.',
     3,  9),

    ('Stack trace points to a null pointer in the request handler. Hotfix branch is open.',
     3, 10),
    ('Hotfix reviewed and merged. Deploying to staging now.',
     2, 10),

    ('Meeting with the client is set for Thursday. Bringing the draft spec for initial sign-off.',
     3, 11);

INSERT INTO Notification (NotiDescription, CommentID, TaskID)
VALUES
    ('kiet.pham97 commented on "Set up project repository".',
     1,  1),
    ('thithu.dang commented on "Set up project repository".',
     2,  1),
    ('thithu.dang commented on "Plan marketing campaign".',
     3,  2),
    ('thithu.dang commented on "Gather user requirements".',
     4,  3),
    ('kiet.pham97 commented on "Gather user requirements".',
     5,  3),
    ('kiet.pham97 commented on "Write SRS document".',
     6,  4),
    ('thithu.dang commented on "Write SRS document".',
     7,  4),
    ('kiet.pham97 commented on "Design student interface".',
     8,  5),
    ('kiet.pham97 commented on "Design high-fidelity UI".',
     9,  6),
    ('thithu.dang commented on "Design high-fidelity UI".',
     10,  6),
    ('thithu.dang commented on "Implement authentication module".',
     11,  7),
    ('kiet.pham97 commented on "Implement authentication module".',
     12,  7),
    ('kiet.pham97 commented on "Implement payment module".',
     13,  8),
    ('thithu.dang commented on "Implement payment module".',
     14,  8),
    ('thithu.dang commented on "Write test cases".',
     15,  9),
    ('thithu.dang commented on "[URGENT] Fix server error".',
     16, 10),
    ('kiet.pham97 commented on "[URGENT] Fix server error".', 
     17, 10),
    ('thithu.dang commented on "Prepare requirements specification".',
     18, 11);

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
    (2,  7,  '2026-02-14 11:21:00'),

    -- "Design student interface" — reporter 1, assignee 2
    (1,  8,  '2026-05-25 10:00:00'),
    (2,  8,  '2026-05-25 10:01:00'),

    -- "Design high-fidelity UI" — reporter 1, assignee 2
    (1,  9,  '2026-05-27 13:00:00'),
    (2,  9,  '2026-05-27 13:01:00'),
    (1,  10, '2026-05-27 14:30:00'),
    (2,  10, '2026-05-27 14:31:00'),

    -- "Implement authentication module" — reporter 1, assignee 3
    (1,  11, '2026-06-05 17:00:00'),
    (2,  11, '2026-06-05 17:01:00'),
    (1,  12, '2026-06-05 18:00:00'),
    (3,  12, '2026-06-05 18:01:00'),

    -- "Implement payment module" — reporter 3, assignee 2
    (1,  13, '2026-06-26 09:00:00'),
    (3,  13, '2026-06-26 09:01:00'),
    (1,  14, '2026-06-26 10:30:00'),
    (2,  14, '2026-06-26 10:31:00'),

    -- "Write test cases" — reporter 1, assignee 3
    (1,  15, '2026-06-24 11:00:00'),
    (3,  15, '2026-06-24 11:01:00'),

    -- "[URGENT] Fix server error" — reporter 1, assignee 3
    (1,  16, '2026-06-28 08:00:00'),
    (3,  16, '2026-06-28 08:01:00'),
    (1,  17, '2026-06-28 09:30:00'),
    (3,  17, '2026-06-28 09:31:00'),

    -- "Prepare requirements specification" — reporter 1, assignee 3
    (1,  18, '2026-05-15 14:00:00'),
    (3,  18, '2026-05-15 14:01:00');
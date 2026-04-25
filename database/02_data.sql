
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
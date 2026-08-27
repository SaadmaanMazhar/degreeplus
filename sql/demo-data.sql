USE defaultdb;

INSERT IGNORE INTO COURSE (Course_Code, Course_Title, Credits, Min_Credits_Required, Department_Name) VALUES
('CSE230', 'Discrete Mathematics', 3.00, 0.00, 'Computer Science and Engineering'),
('CSE250', 'Circuits and Electronics', 3.00, 0.00, 'Computer Science and Engineering'),
('CSE260', 'Digital Logic Design', 3.00, 0.00, 'Computer Science and Engineering'),
('CSE320', 'Data Communications', 3.00, 30.00, 'Computer Science and Engineering'),
('CSE330', 'Numerical Methods', 3.00, 30.00, 'Computer Science and Engineering'),
('CSE341', 'Microprocessors', 3.00, 45.00, 'Computer Science and Engineering'),
('CSE360', 'Computer Networks', 3.00, 45.00, 'Computer Science and Engineering'),
('CSE420', 'Compiler Design', 3.00, 60.00, 'Computer Science and Engineering'),
('CSE470', 'Software Engineering', 3.00, 60.00, 'Computer Science and Engineering'),
('MAT110', 'Calculus and Analytical Geometry', 3.00, 0.00, 'Mathematics'),
('MAT120', 'Linear Algebra and Differential Equations', 3.00, 0.00, 'Mathematics');

INSERT IGNORE INTO REQUIRES (Course_Code, Target, Prerequisite) VALUES
('CSE230', 'CSE230', 'CSE110'),
('CSE250', 'CSE250', 'CSE110'),
('CSE260', 'CSE260', 'CSE111'),
('CSE320', 'CSE320', 'CSE220'),
('CSE330', 'CSE330', 'MAT120'),
('CSE341', 'CSE341', 'CSE260'),
('CSE360', 'CSE360', 'CSE320'),
('CSE420', 'CSE420', 'CSE221'),
('CSE470', 'CSE470', 'CSE370'),
('MAT120', 'MAT120', 'MAT110');

INSERT INTO `USER` (Full_Name, Email, Password_Hash)
SELECT 'Dr. Farhana Rahman', 'advisor@degreeplus.test', '{noop}password123'
WHERE NOT EXISTS (SELECT 1 FROM `USER` WHERE Email = 'advisor@degreeplus.test');
SELECT User_ID INTO @advisor_id FROM `USER` WHERE Email = 'advisor@degreeplus.test';
INSERT IGNORE INTO ADVISOR (User_ID, Department_Name)
VALUES (@advisor_id, 'Computer Science and Engineering');

INSERT INTO `USER` (Full_Name, Email, Password_Hash)
SELECT 'Nusrat Jahan', 'admin@degreeplus.test', '{noop}password123'
WHERE NOT EXISTS (SELECT 1 FROM `USER` WHERE Email = 'admin@degreeplus.test');
SELECT User_ID INTO @admin_id FROM `USER` WHERE Email = 'admin@degreeplus.test';
INSERT IGNORE INTO ADMIN (User_ID, Department_Managed)
VALUES (@admin_id, 'Computer Science and Engineering');

INSERT INTO `USER` (Full_Name, Email, Password_Hash)
SELECT 'Dr. Mahmud Hasan', 'faculty1@degreeplus.test', '{noop}password123'
WHERE NOT EXISTS (SELECT 1 FROM `USER` WHERE Email = 'faculty1@degreeplus.test');
SELECT User_ID INTO @faculty1_id FROM `USER` WHERE Email = 'faculty1@degreeplus.test';
INSERT IGNORE INTO FACULTY (User_ID, Department_Name, Designation)
VALUES (@faculty1_id, 'Computer Science and Engineering', 'Associate Professor');

INSERT INTO `USER` (Full_Name, Email, Password_Hash)
SELECT 'Dr. Samia Islam', 'faculty2@degreeplus.test', '{noop}password123'
WHERE NOT EXISTS (SELECT 1 FROM `USER` WHERE Email = 'faculty2@degreeplus.test');
SELECT User_ID INTO @faculty2_id FROM `USER` WHERE Email = 'faculty2@degreeplus.test';
INSERT IGNORE INTO FACULTY (User_ID, Department_Name, Designation)
VALUES (@faculty2_id, 'Computer Science and Engineering', 'Assistant Professor');

INSERT INTO `USER` (Full_Name, Email, Password_Hash)
SELECT 'Rafi Ahmed', 'rafi@degreeplus.test', '{noop}password123'
WHERE NOT EXISTS (SELECT 1 FROM `USER` WHERE Email = 'rafi@degreeplus.test');
SELECT User_ID INTO @student2_id FROM `USER` WHERE Email = 'rafi@degreeplus.test';
INSERT IGNORE INTO STUDENT (
    User_ID,
    Department_Name,
    Consecutive_Probation_Count,
    Academic_Status,
    Current_Risk_Level,
    Advisor_id
) VALUES
(@student2_id, 'Computer Science and Engineering', 1, 'ON_PROBATION', 'MEDIUM', @advisor_id);

INSERT INTO `USER` (Full_Name, Email, Password_Hash)
SELECT 'Maliha Chowdhury', 'maliha@degreeplus.test', '{noop}password123'
WHERE NOT EXISTS (SELECT 1 FROM `USER` WHERE Email = 'maliha@degreeplus.test');
SELECT User_ID INTO @student3_id FROM `USER` WHERE Email = 'maliha@degreeplus.test';
INSERT IGNORE INTO STUDENT (
    User_ID,
    Department_Name,
    Consecutive_Probation_Count,
    Academic_Status,
    Current_Risk_Level,
    Advisor_id
) VALUES
(@student3_id, 'Computer Science and Engineering', 0, 'GOOD_STANDING', 'LOW', @advisor_id);

SELECT User_ID INTO @demo_student_id FROM `USER` WHERE Email = 'student@degreeplus.test';

UPDATE STUDENT
SET Advisor_id = @advisor_id
WHERE User_ID = @demo_student_id;

INSERT IGNORE INTO TAKES (
    User_ID,
    Course_Code,
    Semester_Name,
    Attempt_Number,
    Obtained_Grade,
    Grade_Point,
    Credits_Earned,
    Is_Completed
) VALUES
(@demo_student_id, 'MAT110', 'Spring 2025', 1, 'A-', 3.70, 3.00, TRUE),
(@demo_student_id, 'MAT120', 'Summer 2025', 1, 'B+', 3.30, 3.00, TRUE),
(@student2_id, 'CSE110', 'Spring 2025', 1, 'C', 2.00, 3.00, TRUE),
(@student2_id, 'CSE111', 'Summer 2025', 1, 'F', 0.00, 0.00, TRUE),
(@student2_id, 'CSE111', 'Fall 2025', 2, 'D', 1.00, 3.00, TRUE),
(@student2_id, 'MAT110', 'Spring 2025', 1, 'C+', 2.30, 3.00, TRUE),
(@student3_id, 'CSE110', 'Spring 2025', 1, 'B', 3.00, 3.00, TRUE),
(@student3_id, 'CSE111', 'Summer 2025', 1, 'B-', 2.70, 3.00, TRUE),
(@student3_id, 'CSE220', 'Fall 2025', 1, 'C+', 2.30, 3.00, TRUE),
(@student3_id, 'CSE221', 'Spring 2026', 1, 'B', 3.00, 3.00, TRUE);

INSERT IGNORE INTO WISHLIST_PERIOD (
    Wishlist_ID,
    Semester_Name,
    Start_Date,
    End_Date,
    Is_Active
) VALUES
(1, 'Summer 2026', '2026-03-01', '2026-03-15', TRUE);

INSERT IGNORE INTO STUDENT_WISHLIST (
    Wishlist_Header_ID,
    Submitted_At,
    SID,
    Wishlist_ID
) VALUES
(1, '2026-03-05 10:15:00', @demo_student_id, 1),
(2, '2026-03-06 14:20:00', @student2_id, 1),
(3, '2026-03-07 09:30:00', @student3_id, 1);

INSERT IGNORE INTO SELECTS_WISHLIST_COURSE (
    Wishlist_Item_ID,
    Added_At,
    Wishlist_Header_id,
    Course_Code
) VALUES
(1, '2026-03-05 10:16:00', 1, 'CSE221'),
(2, '2026-03-05 10:17:00', 1, 'CSE370'),
(3, '2026-03-06 14:21:00', 2, 'CSE220'),
(4, '2026-03-06 14:22:00', 2, 'CSE230'),
(5, '2026-03-07 09:31:00', 3, 'CSE370'),
(6, '2026-03-07 09:32:00', 3, 'CSE470');

INSERT IGNORE INTO COURSE_SECTION (
    Section_ID,
    Semester_Name,
    Section_Number,
    Capacity,
    Enrolled_Count,
    Start_Time,
    End_Time,
    Exam_Date,
    Exam_Start_Time,
    Exam_End_Time,
    Room_Number,
    Course_Code,
    Faculty_id,
    Admin_ID
) VALUES
(1, 'Summer 2026', '01', 30, 22, '09:30:00', '10:50:00', '2026-06-20', '09:00:00', '11:00:00', 'UB40301', 'CSE221', @faculty1_id, @admin_id),
(2, 'Summer 2026', '02', 30, 28, '11:00:00', '12:20:00', '2026-06-22', '12:00:00', '14:00:00', 'UB40302', 'CSE370', @faculty2_id, @admin_id),
(3, 'Summer 2026', '01', 35, 18, '14:00:00', '15:20:00', '2026-06-24', '15:00:00', '17:00:00', 'UB40303', 'CSE470', @faculty1_id, @admin_id);

INSERT IGNORE INTO Days (Class_days, Section) VALUES
('Sunday', 1),
('Tuesday', 1),
('Monday', 2),
('Wednesday', 2),
('Sunday', 3),
('Thursday', 3);

INSERT IGNORE INTO SEMESTER_PLAN (
    Plan_ID,
    Semester_Name,
    Created_By_Role,
    Is_Approved,
    SID
) VALUES
(1, 'Summer 2026', 'STUDENT', FALSE, @demo_student_id),
(2, 'Summer 2026', 'ADVISOR', TRUE, @student2_id),
(3, 'Summer 2026', 'STUDENT', TRUE, @student3_id);

INSERT IGNORE INTO CONTAINS_SECTION (
    Plan_ID,
    Section_id,
    Plan_Item_ID,
    Added_At,
    Validation_Status
) VALUES
(1, 1, 1, '2026-03-18 11:00:00', 'VALID'),
(1, 2, 2, '2026-03-18 11:05:00', 'INVALID'),
(2, 1, 3, '2026-03-18 12:00:00', 'VALID'),
(3, 2, 4, '2026-03-18 13:00:00', 'VALID'),
(3, 3, 5, '2026-03-18 13:10:00', 'PENDING');

INSERT IGNORE INTO RISK_ALERT (
    Alert_ID,
    Risk_Type,
    Severity_Level,
    Trigger_Reason,
    Detected_At,
    SID
) VALUES
(1, 'LOW_CGPA', 'MEDIUM', 'CGPA below 2.00 after repeated CSE111 attempt.', '2026-01-10 09:00:00', @student2_id),
(2, 'GRADUATION_RISK', 'LOW', 'Student should meet advisor before next registration cycle.', '2026-01-12 10:30:00', @student3_id);

INSERT IGNORE INTO ADVISING_MESSAGE (
    User_ID,
    Message_ID,
    Message_Text,
    Sent_At,
    SID
) VALUES
(@advisor_id, 1, 'Please meet me this week to discuss your Summer 2026 plan.', '2026-03-10 10:00:00', @student2_id),
(@student2_id, 2, 'I am available after 2 PM on Wednesday.', '2026-03-10 12:45:00', @student2_id),
(@advisor_id, 3, 'Your plan is approved with CSE221 first. We will delay CSE370 until prerequisites are cleared.', '2026-03-11 09:15:00', @student2_id),
(@student3_id, 4, 'Can I take CSE470 with CSE370 completed this semester?', '2026-03-12 16:20:00', @student3_id);

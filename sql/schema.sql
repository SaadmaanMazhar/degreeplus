CREATE DATABASE IF NOT EXISTS degreeplus;
USE degreeplus;

CREATE TABLE `USER` (
    User_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Full_Name VARCHAR(120) NOT NULL,
    Email VARCHAR(160) NOT NULL UNIQUE,
    Password_Hash VARCHAR(255) NOT NULL
);

CREATE TABLE ADVISOR (
    User_ID BIGINT PRIMARY KEY,
    Department_Name VARCHAR(120) NOT NULL,
    CONSTRAINT fk_advisor_user
        FOREIGN KEY (User_ID) REFERENCES `USER`(User_ID)
        ON DELETE CASCADE
);

CREATE TABLE STUDENT (
    User_ID BIGINT PRIMARY KEY,
    Department_Name VARCHAR(120) NOT NULL,
    Consecutive_Probation_Count INT NOT NULL DEFAULT 0,
    Academic_Status ENUM('GOOD_STANDING', 'ON_PROBATION', 'SUSPENDED', 'DISMISSED') NOT NULL DEFAULT 'GOOD_STANDING',
    Current_Risk_Level ENUM('NONE', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL') NOT NULL DEFAULT 'NONE',
    Advisor_id BIGINT NULL,
    CONSTRAINT fk_student_user
        FOREIGN KEY (User_ID) REFERENCES `USER`(User_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_student_advisor
        FOREIGN KEY (Advisor_id) REFERENCES ADVISOR(User_ID)
        ON DELETE SET NULL
);

CREATE TABLE ADMIN (
    User_ID BIGINT PRIMARY KEY,
    Department_Managed VARCHAR(120) NOT NULL,
    CONSTRAINT fk_admin_user
        FOREIGN KEY (User_ID) REFERENCES `USER`(User_ID)
        ON DELETE CASCADE
);

CREATE TABLE FACULTY (
    User_ID BIGINT PRIMARY KEY,
    Department_Name VARCHAR(120) NOT NULL,
    Designation VARCHAR(120) NOT NULL,
    CONSTRAINT fk_faculty_user
        FOREIGN KEY (User_ID) REFERENCES `USER`(User_ID)
        ON DELETE CASCADE
);

CREATE TABLE COURSE (
    Course_Code VARCHAR(20) PRIMARY KEY,
    Course_Title VARCHAR(160) NOT NULL,
    Credits DECIMAL(4,2) NOT NULL,
    Min_Credits_Required DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    Department_Name VARCHAR(120) NOT NULL,
    CONSTRAINT chk_course_credits CHECK (Credits > 0),
    CONSTRAINT chk_course_min_credits CHECK (Min_Credits_Required >= 0)
);

CREATE TABLE COURSE_SECTION (
    Section_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Semester_Name VARCHAR(40) NOT NULL,
    Section_Number VARCHAR(20) NOT NULL,
    Capacity INT NOT NULL,
    Enrolled_Count INT NOT NULL DEFAULT 0,
    Start_Time TIME NOT NULL,
    End_Time TIME NOT NULL,
    Exam_Date DATE NULL,
    Exam_Start_Time TIME NULL,
    Exam_End_Time TIME NULL,
    Room_Number VARCHAR(40) NOT NULL,
    Course_Code VARCHAR(20) NOT NULL,
    Faculty_id BIGINT NOT NULL,
    Admin_ID BIGINT NOT NULL,
    CONSTRAINT fk_section_course
        FOREIGN KEY (Course_Code) REFERENCES COURSE(Course_Code)
        ON DELETE RESTRICT,
    CONSTRAINT fk_section_faculty
        FOREIGN KEY (Faculty_id) REFERENCES FACULTY(User_ID)
        ON DELETE RESTRICT,
    CONSTRAINT fk_section_admin
        FOREIGN KEY (Admin_ID) REFERENCES ADMIN(User_ID)
        ON DELETE RESTRICT,
    CONSTRAINT chk_section_capacity CHECK (Capacity > 0),
    CONSTRAINT chk_section_enrolled CHECK (Enrolled_Count >= 0 AND Enrolled_Count <= Capacity),
    CONSTRAINT chk_section_time CHECK (Start_Time < End_Time)
);

CREATE TABLE Days (
    Class_days VARCHAR(20) NOT NULL,
    Section BIGINT NOT NULL,
    PRIMARY KEY (Class_days, Section),
    CONSTRAINT fk_days_section
        FOREIGN KEY (Section) REFERENCES COURSE_SECTION(Section_ID)
        ON DELETE CASCADE
);

CREATE TABLE SEMESTER_PLAN (
    Plan_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Semester_Name VARCHAR(40) NOT NULL,
    Created_By_Role ENUM('STUDENT', 'ADVISOR') NOT NULL,
    Is_Approved BOOLEAN NOT NULL DEFAULT FALSE,
    SID BIGINT NOT NULL,
    CONSTRAINT fk_plan_student
        FOREIGN KEY (SID) REFERENCES STUDENT(User_ID)
        ON DELETE CASCADE
);

CREATE TABLE WISHLIST_PERIOD (
    Wishlist_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Semester_Name VARCHAR(40) NOT NULL,
    Start_Date DATE NOT NULL,
    End_Date DATE NOT NULL,
    Is_Active BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT chk_wishlist_period_dates CHECK (Start_Date <= End_Date)
);

CREATE TABLE STUDENT_WISHLIST (
    Wishlist_Header_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Submitted_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SID BIGINT NOT NULL,
    Wishlist_ID BIGINT NOT NULL,
    CONSTRAINT fk_student_wishlist_student
        FOREIGN KEY (SID) REFERENCES STUDENT(User_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_student_wishlist_period
        FOREIGN KEY (Wishlist_ID) REFERENCES WISHLIST_PERIOD(Wishlist_ID)
        ON DELETE CASCADE
);

CREATE TABLE SELECTS_WISHLIST_COURSE (
    Wishlist_Item_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Added_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Wishlist_Header_id BIGINT NOT NULL,
    Course_Code VARCHAR(20) NOT NULL,
    CONSTRAINT fk_wishlist_item_header
        FOREIGN KEY (Wishlist_Header_id) REFERENCES STUDENT_WISHLIST(Wishlist_Header_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_item_course
        FOREIGN KEY (Course_Code) REFERENCES COURSE(Course_Code)
        ON DELETE RESTRICT,
    CONSTRAINT uq_wishlist_course UNIQUE (Wishlist_Header_id, Course_Code)
);

CREATE TABLE CONTAINS_SECTION (
    Plan_ID BIGINT NOT NULL,
    Section_id BIGINT NOT NULL,
    Plan_Item_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Added_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Validation_Status ENUM('PENDING', 'VALID', 'INVALID') NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_contains_plan
        FOREIGN KEY (Plan_ID) REFERENCES SEMESTER_PLAN(Plan_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_contains_section
        FOREIGN KEY (Section_id) REFERENCES COURSE_SECTION(Section_ID)
        ON DELETE CASCADE,
    CONSTRAINT uq_plan_section UNIQUE (Plan_ID, Section_id)
);

CREATE TABLE RISK_ALERT (
    Alert_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Risk_Type VARCHAR(80) NOT NULL,
    Severity_Level ENUM('LOW', 'MEDIUM', 'HIGH', 'CRITICAL') NOT NULL,
    Trigger_Reason VARCHAR(255) NOT NULL,
    Detected_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SID BIGINT NOT NULL,
    CONSTRAINT fk_risk_alert_student
        FOREIGN KEY (SID) REFERENCES STUDENT(User_ID)
        ON DELETE CASCADE
);

CREATE TABLE ADVISING_MESSAGE (
    User_ID BIGINT NOT NULL,
    Message_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Message_Text TEXT NOT NULL,
    Sent_At TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    SID BIGINT NOT NULL,
    CONSTRAINT fk_message_sender
        FOREIGN KEY (User_ID) REFERENCES `USER`(User_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_message_student
        FOREIGN KEY (SID) REFERENCES STUDENT(User_ID)
        ON DELETE CASCADE
);

CREATE TABLE REQUIRES (
    Course_Code VARCHAR(20) NOT NULL,
    Target VARCHAR(20) NOT NULL,
    Prerequisite VARCHAR(20) NOT NULL,
    PRIMARY KEY (Course_Code, Prerequisite),
    CONSTRAINT fk_requires_course
        FOREIGN KEY (Course_Code) REFERENCES COURSE(Course_Code)
        ON DELETE CASCADE,
    CONSTRAINT fk_requires_target
        FOREIGN KEY (Target) REFERENCES COURSE(Course_Code)
        ON DELETE CASCADE,
    CONSTRAINT fk_requires_prerequisite
        FOREIGN KEY (Prerequisite) REFERENCES COURSE(Course_Code)
        ON DELETE CASCADE,
    CONSTRAINT chk_requires_target_match CHECK (Course_Code = Target),
    CONSTRAINT chk_requires_not_self CHECK (Target <> Prerequisite)
);

CREATE TABLE TAKES (
    User_ID BIGINT NOT NULL,
    Course_Code VARCHAR(20) NOT NULL,
    Record_ID BIGINT PRIMARY KEY AUTO_INCREMENT,
    Semester_Name VARCHAR(40) NOT NULL,
    Attempt_Number INT NOT NULL,
    Obtained_Grade VARCHAR(4) NOT NULL,
    Grade_Point DECIMAL(3,2) NOT NULL,
    Credits_Earned DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    Is_Completed BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_takes_student
        FOREIGN KEY (User_ID) REFERENCES STUDENT(User_ID)
        ON DELETE CASCADE,
    CONSTRAINT fk_takes_course
        FOREIGN KEY (Course_Code) REFERENCES COURSE(Course_Code)
        ON DELETE RESTRICT,
    CONSTRAINT uq_takes_student_course UNIQUE (User_ID, Course_Code, Attempt_Number),
    CONSTRAINT chk_takes_grade_point CHECK (Grade_Point BETWEEN 0.00 AND 4.00),
    CONSTRAINT chk_takes_credits_earned CHECK (Credits_Earned >= 0)
);

CREATE INDEX idx_student_advisor ON STUDENT(Advisor_id);
CREATE INDEX idx_section_course ON COURSE_SECTION(Course_Code);
CREATE INDEX idx_section_faculty ON COURSE_SECTION(Faculty_id);
CREATE INDEX idx_plan_student ON SEMESTER_PLAN(SID);
CREATE INDEX idx_wishlist_student ON STUDENT_WISHLIST(SID);
CREATE INDEX idx_risk_alert_student ON RISK_ALERT(SID);
CREATE INDEX idx_message_student ON ADVISING_MESSAGE(SID);
CREATE INDEX idx_requires_target ON REQUIRES(Target);
CREATE INDEX idx_takes_student ON TAKES(User_ID);
CREATE INDEX idx_takes_course ON TAKES(Course_Code);

INSERT INTO COURSE (Course_Code, Course_Title, Credits, Min_Credits_Required, Department_Name) VALUES
('CSE110', 'Programming Language I', 3.00, 0.00, 'Computer Science and Engineering'),
('CSE111', 'Programming Language II', 3.00, 0.00, 'Computer Science and Engineering'),
('CSE220', 'Data Structures', 3.00, 0.00, 'Computer Science and Engineering'),
('CSE221', 'Algorithms', 3.00, 0.00, 'Computer Science and Engineering'),
('CSE370', 'Database Systems', 3.00, 0.00, 'Computer Science and Engineering'),
('CSE400', 'Thesis / Internship', 6.00, 75.00, 'Computer Science and Engineering');

INSERT INTO REQUIRES (Course_Code, Target, Prerequisite) VALUES
('CSE111', 'CSE111', 'CSE110'),
('CSE220', 'CSE220', 'CSE111'),
('CSE221', 'CSE221', 'CSE220'),
('CSE370', 'CSE370', 'CSE221'),
('CSE400', 'CSE400', 'CSE370');

-- Demo login. The {noop} prefix is supported by Spring Security for local coursework demos.
-- Use POST /api/auth/register/student to create BCrypt-backed users for normal use.
INSERT INTO `USER` (Full_Name, Email, Password_Hash) VALUES
('Demo Student', 'student@degreeplus.test', '{noop}password123');

SET @demo_student_id = LAST_INSERT_ID();

INSERT INTO STUDENT (
    User_ID,
    Department_Name,
    Consecutive_Probation_Count,
    Academic_Status,
    Current_Risk_Level,
    Advisor_id
) VALUES
(@demo_student_id, 'Computer Science and Engineering', 0, 'GOOD_STANDING', 'NONE', NULL);

INSERT INTO TAKES (
    User_ID,
    Course_Code,
    Semester_Name,
    Attempt_Number,
    Obtained_Grade,
    Grade_Point,
    Credits_Earned,
    Is_Completed
) VALUES
(@demo_student_id, 'CSE110', 'Spring 2025', 1, 'A', 4.00, 3.00, TRUE),
(@demo_student_id, 'CSE111', 'Summer 2025', 1, 'B+', 3.30, 3.00, TRUE),
(@demo_student_id, 'CSE220', 'Fall 2025', 1, 'B', 3.00, 3.00, TRUE);

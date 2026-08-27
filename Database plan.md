# DegreePlus - System Architecture & Database Design Specification

## System Overview
**DegreePlus** is a student-centric academic management and advising engine designed to streamline course registration, academic tracking, demand-based scheduling, and proactive graduation risk mitigation within a university environment.

---

## 1. Complete Feature Breakdown

### Feature 1: Academic Progress Tracker
* **Description:** Tracks and maintains student academic performance throughout their university lifecycle.
* **Functionality:**
  * Stores individual course history, including letter grades, grade points, and earned credit hours.
  * Tracks historical course attempts to handle repeat/retake policies.
  * Dynamically calculates cumulative metrics including `Current_CGPA`, `Total_Credits_Completed`, and `Total_Semesters_Completed`.

### Feature 2: Prerequisite & Credit Eligibility Engine
* **Description:** Prevents unauthorized course enrollment by enforcing academic dependency constraints prior to registration.
* **Functionality:**
  * **Course-Based Prerequisites:** Evaluates recursive course dependencies (e.g., CSE220 -> CSE221 -> CSE370) by verifying passed course records.
  * **Credit-Based Prerequisites:** Enforces global credit thresholds (e.g., minimum 75 completed credits required for CSE400 Thesis/Internship).

### Feature 3: Conflict-Free Advising & Controlled Registration
* **Description:** Handles real-time schedule assembly while enforcing operational boundaries.
* **Functionality:**
  * **Time & Exam Conflict Prevention:** Validates overlapping weekly class schedules and exam dates/times before section insertion.
  * **Registration Credit Boundaries:** Enforces a minimum credit floor (>= 6 credits) and maximum credit ceiling (<= 16 credits) per semester plan.
  * **Advising Windows:** Restricts schedule creation/modification strictly to active `ADVISING_PERIOD` timelines.
  * **Probation Governance:** Automatically flags students with CGPA < 2.00 as `On_Probation` and restricts plan assembly exclusively to their assigned `ADVISOR`.

### Feature 4: Course Demand Wishlist & Capacity Planning
* **Description:** Captures student course demand prior to term scheduling to optimize institutional resource allocation.
* **Functionality:**
  * **Demand Collection Window:** Opens a time-bounded `WISHLIST_PERIOD` allowing students to express interest in upcoming courses.
  * **Validation Re-use:** Re-uses prerequisite and eligibility rules during wishlist submission.
  * **Demand Analytics:** Aggregates unique student requests per course and provides administrators with automated section capacity recommendations (Total Demand Count / 30).

### Feature 5: Graduation Risk Alert & Advising Communication System
* **Description:** Identifies academic vulnerability, applies institutional policy enforcement, and opens early intervention channels.
* **Functionality:**
  * **Multi-Tier Risk Assessment:**
    * **LOW Risk:** 2.00 <= CGPA < 2.25.
    * **MEDIUM Risk:** CGPA < 2.00 (1st term) OR failed the same course twice.
    * **HIGH Risk:** CGPA < 2.00 for 2 consecutive terms OR failed same course twice and currently retaking.
    * **CRITICAL / DISMISSED:** CGPA < 2.00 for 3 consecutive terms OR failed the same course 3 times.
  * **Automatic Advisor Assignment:** Assigns an academic advisor immediately upon reaching LOW risk or higher.
  * **2-Way Advising Thread:** Enables direct messaging between students and assigned advisors for guidance.

### Feature 6: Administrative & Advisor Operations Dashboards
* **Description:** Centralized control center providing specialized views for operational management.
* **Functionality:**
  * **Advisor Dashboard:** Provides access to assigned student rosters, academic histories, risk severity indicators, direct messaging channels, and schedule overriding tools for probation students.
  * **Admin Dashboard:** Converts wishlist demand analytics into active `COURSE_SECTION` offerings, sets class/exam schedules, assigns room numbers, and maps `FACULTY` instructors to sections.

---

## 2. Chen Notation ERD Data Dictionary

*Note: In Chen Notation, Primary Keys are underlined. Here they are denoted with **(PK)**. Multivalued or derived attributes are explicitly described.*

### Entities (Rectangles) & Attributes (Ovals)

* **`USER`** (Supertype Entity)
  * `User_ID` **(PK)**
  * `Full_Name`
  * `Email`
  * `Password_Hash`
  * `Role` (Student, Advisor, Admin, Faculty)
  * `Created_At`

* **`STUDENT`** (Subtype Entity of USER)
  * `User_ID` **(PK)** - *Inherited*
  * `Department_Name`
  * `Current_CGPA` - *Derived*
  * `Total_Credits_Completed` - *Derived*
  * `Total_Semesters_Completed` - *Derived*
  * `Consecutive_Probation_Count`
  * `Academic_Status`
  * `Current_Risk_Level`

* **`ADVISOR`** (Subtype Entity of USER)
  * `User_ID` **(PK)** - *Inherited*
  * `Department_Name`

* **`ADMIN`** (Subtype Entity of USER)
  * `User_ID` **(PK)** - *Inherited*
  * `Department_Managed`

* **`FACULTY`** (Subtype Entity of USER)
  * `User_ID` **(PK)** - *Inherited*
  * `Department_Name`
  * `Designation`

* **`COURSE`**
  * `Course_Code` **(PK)**
  * `Course_Title`
  * `Credits`
  * `Min_Credits_Required`
  * `Department_Name`

* **`COURSE_SECTION`**
  * `Section_ID` **(PK)**
  * `Semester_Name`
  * `Section_Number`
  * `Capacity`
  * `Enrolled_Count`
  * `Class_Days`
  * `Start_Time`
  * `End_Time`
  * `Exam_Date`
  * `Exam_Start_Time`
  * `Exam_End_Time`
  * `Room_Number`

* **`SEMESTER_PLAN`**
  * `Plan_ID` **(PK)**
  * `Semester_Name`
  * `Created_By_Role`
  * `Is_Approved`
  * `Total_Plan_Credits` - *Derived*

* **`WISHLIST_PERIOD`**
  * `Wishlist_ID` **(PK)**
  * `Semester_Name`
  * `Start_Date`
  * `End_Date`
  * `Is_Active`

* **`STUDENT_WISHLIST`**
  * `Wishlist_Header_ID` **(PK)**
  * `Submitted_At`

* **`RISK_ALERT`**
  * `Alert_ID` **(PK)**
  * `Risk_Type`
  * `Severity_Level`
  * `Trigger_Reason`
  * `Detected_At`

* **`ADVISING_MESSAGE`**
  * `Message_ID` **(PK)**
  * `Message_Text`
  * `Sent_At`

---

## 3. Relationships (Diamonds)

*Note: In Chen Notation, participation is defined as **Total** (double line, meaning every entity instance must participate) or **Partial** (single line, meaning participation is optional). Cardinalities are M:N, 1:N, or 1:1.*

### A. Relationships with Attributes (Associative Diamonds)

**1. `TAKES`**
* **Entities & Participation:** `STUDENT` (Partial) <--> `COURSE` (Partial)
* **Cardinality:** M : N
* **Relationship Attributes:**
  * `Record_ID`
  * `Semester_Name`
  * `Attempt_Number`
  * `Obtained_Grade`
  * `Grade_Point`
  * `Credits_Earned`
  * `Is_Completed`

**2. `REQUIRES`** (Recursive)
* **Entities & Participation:** `COURSE` Target (Partial) <--> `COURSE` Prerequisite (Partial)
* **Cardinality:** M : N
* **Relationship Attributes:**
  * `Rule_ID`

**3. `CONTAINS_SECTION`**
* **Entities & Participation:** `SEMESTER_PLAN` (Total) <--> `COURSE_SECTION` (Partial)
* **Cardinality:** M : N
* **Relationship Attributes:**
  * `Plan_Item_ID`
  * `Added_At`
  * `Validation_Status`

**4. `SELECTS_WISHLIST_COURSE`**
* **Entities & Participation:** `STUDENT_WISHLIST` (Total) <--> `COURSE` (Partial)
* **Cardinality:** M : N
* **Relationship Attributes:**
  * `Wishlist_Item_ID`
  * `Added_At`

### B. Standard Binary Relationships (Diamonds without Attributes)

**5. `IS_A`** (Specialization hierarchy)
* **Entities & Participation:** `USER` (Total) <--> `STUDENT`, `ADVISOR`, `ADMIN`, `FACULTY` (Total)
* **Cardinality:** 1 : 1 (Inheritance mapping)
* **Description:** Represents disjoint total specialization. Every user must belong to one of these roles.

**6. `ADVISES`**
* **Entities & Participation:** `ADVISOR` (Partial) <--> `STUDENT` (Partial)
* **Cardinality:** 1 : N
* **Description:** An advisor is assigned to multiple at-risk students. Regular students do not have an active assignment (Partial participation for Student).

**7. `OFFERS`**
* **Entities & Participation:** `COURSE` (Partial) <--> `COURSE_SECTION` (Total)
* **Cardinality:** 1 : N
* **Description:** A course catalog item generates multiple term sections. Every section must belong to a course.

**8. `TEACHES`**
* **Entities & Participation:** `FACULTY` (Partial) <--> `COURSE_SECTION` (Total)
* **Cardinality:** 1 : N
* **Description:** A faculty member teaches sections. Every section must have an assigned faculty member.

**9. `CREATES_SECTION`**
* **Entities & Participation:** `ADMIN` (Partial) <--> `COURSE_SECTION` (Total)
* **Cardinality:** 1 : N
* **Description:** Admins generate sections based on wishlist demand. 

**10. `BUILDS_PLAN`**
* **Entities & Participation:** `STUDENT` (Partial) <--> `SEMESTER_PLAN` (Total)
* **Cardinality:** 1 : N
* **Description:** A student authors their draft registration plan. Every plan belongs to a single student.

**11. `SUBMITS_WISHLIST`**
* **Entities & Participation:** `STUDENT` (Partial) <--> `STUDENT_WISHLIST` (Total)
* **Cardinality:** 1 : N
* **Description:** A student submits a wishlist header. Every wishlist header strictly belongs to a student.

**12. `GOVERNS`**
* **Entities & Participation:** `WISHLIST_PERIOD` (Partial) <--> `STUDENT_WISHLIST` (Total)
* **Cardinality:** 1 : N
* **Description:** An active administrative window collects multiple student wishlists. Every wishlist submission is tied to a specific period.

**13. `FLAGS_RISK`**
* **Entities & Participation:** `STUDENT` (Partial) <--> `RISK_ALERT` (Total)
* **Cardinality:** 1 : N
* **Description:** System logs alerts for a student. Only at-risk students get alerts (Partial for student), but every alert must belong to a student (Total for alert).

**14. `SENDS_MESSAGE`**
* **Entities & Participation:** `USER` (Partial) <--> `ADVISING_MESSAGE` (Total)
* **Cardinality:** 1 : N
* **Description:** Tracks the sender (Student or Advisor) of a chat message. Every message must have a sender.

**15. `RECEIVES_CHAT`**
* **Entities & Participation:** `STUDENT` (Partial) <--> `ADVISING_MESSAGE` (Total)
* **Cardinality:** 1 : N
* **Description:** Maps all communication logs back to the subject student's advising thread.
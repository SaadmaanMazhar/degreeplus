package com.degreeplus.student;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@Service
public class ProgressService {
    private final JdbcTemplate jdbcTemplate;

    public ProgressService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public ProgressResponse getProgress(Long studentUserId) {
        ensureStudentExists(studentUserId);
        List<CourseAttempt> history = getHistory(studentUserId);

        Map<String, CourseAttempt> latestCompletedByCourse = new LinkedHashMap<>();
        history.stream()
                .filter(CourseAttempt::completed)
                .sorted(Comparator.comparing(CourseAttempt::courseCode)
                        .thenComparing(CourseAttempt::attemptNumber)
                        .thenComparing(CourseAttempt::recordId))
                .forEach(attempt -> latestCompletedByCourse.put(attempt.courseCode(), attempt));

        BigDecimal weightedPoints = BigDecimal.ZERO;
        BigDecimal attemptedCredits = BigDecimal.ZERO;
        BigDecimal earnedCredits = BigDecimal.ZERO;

        for (CourseAttempt attempt : latestCompletedByCourse.values()) {
            BigDecimal courseCredits = courseCredits(attempt.courseCode());
            weightedPoints = weightedPoints.add(attempt.gradePoint().multiply(courseCredits));
            attemptedCredits = attemptedCredits.add(courseCredits);
            earnedCredits = earnedCredits.add(attempt.creditsEarned());
        }

        BigDecimal cgpa = attemptedCredits.compareTo(BigDecimal.ZERO) == 0
                ? BigDecimal.ZERO
                : weightedPoints.divide(attemptedCredits, 2, RoundingMode.HALF_UP);

        Integer semesters = jdbcTemplate.queryForObject("""
                SELECT COUNT(DISTINCT Semester_Name)
                FROM TAKES
                WHERE User_ID = ? AND Is_Completed = TRUE
                """, Integer.class, studentUserId);

        return new ProgressResponse(cgpa, earnedCredits, semesters == null ? 0 : semesters, history);
    }

    public List<CourseAttempt> getHistory(Long studentUserId) {
        return jdbcTemplate.query("""
                SELECT t.Record_ID AS record_id,
                       t.Course_Code AS course_code,
                       c.Course_Title AS course_title,
                       t.Semester_Name AS semester_name,
                       t.Attempt_Number AS attempt_number,
                       t.Obtained_Grade AS obtained_grade,
                       t.Grade_Point AS grade_point,
                       t.Credits_Earned AS credits_earned,
                       t.Is_Completed AS is_completed
                FROM TAKES t
                JOIN COURSE c ON c.Course_Code = t.Course_Code
                WHERE t.User_ID = ?
                ORDER BY t.Semester_Name DESC, t.Course_Code, t.Attempt_Number DESC
                """, (rs, rowNum) -> new CourseAttempt(
                rs.getLong("record_id"),
                rs.getString("course_code"),
                rs.getString("course_title"),
                rs.getString("semester_name"),
                rs.getInt("attempt_number"),
                rs.getString("obtained_grade"),
                rs.getBigDecimal("grade_point"),
                rs.getBigDecimal("credits_earned"),
                rs.getBoolean("is_completed")
        ), studentUserId);
    }

    @Transactional
    public void addAttempt(Long studentUserId, CourseAttemptRequest request) {
        ensureStudentExists(studentUserId);
        ensureCourseExists(request.courseCode());

        Integer attemptNumber = request.attemptNumber();
        if (attemptNumber == null) {
            Integer maxAttempt = jdbcTemplate.queryForObject("""
                    SELECT COALESCE(MAX(Attempt_Number), 0)
                    FROM TAKES
                    WHERE User_ID = ? AND Course_Code = ?
                    """, Integer.class, studentUserId, request.courseCode());
            attemptNumber = (maxAttempt == null ? 0 : maxAttempt) + 1;
        }

        jdbcTemplate.update("""
                INSERT INTO TAKES (
                    User_ID,
                    Course_Code,
                    Semester_Name,
                    Attempt_Number,
                    Obtained_Grade,
                    Grade_Point,
                    Credits_Earned,
                    Is_Completed
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                studentUserId,
                request.courseCode(),
                request.semesterName(),
                attemptNumber,
                request.obtainedGrade(),
                request.gradePoint(),
                request.creditsEarned(),
                request.completed() == null || request.completed());

        getProgress(studentUserId);
    }

    public BigDecimal completedCredits(Long studentUserId) {
        return getProgress(studentUserId).totalCreditsCompleted();
    }

    private BigDecimal courseCredits(String courseCode) {
        return jdbcTemplate.queryForObject("""
                SELECT Credits FROM COURSE WHERE Course_Code = ?
                """, BigDecimal.class, courseCode);
    }

    private void ensureStudentExists(Long studentUserId) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM STUDENT WHERE User_ID = ?",
                Integer.class,
                studentUserId
        );
        if (count == null || count == 0) {
            throw new NoSuchElementException("Student profile was not found.");
        }
    }

    private void ensureCourseExists(String courseCode) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM COURSE WHERE Course_Code = ?",
                Integer.class,
                courseCode
        );
        if (count == null || count == 0) {
            throw new NoSuchElementException("Course was not found.");
        }
    }
}

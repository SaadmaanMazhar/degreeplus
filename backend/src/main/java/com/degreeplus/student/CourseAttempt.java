package com.degreeplus.student;

import java.math.BigDecimal;

public record CourseAttempt(
        Long recordId,
        String courseCode,
        String courseTitle,
        String semesterName,
        Integer attemptNumber,
        String obtainedGrade,
        BigDecimal gradePoint,
        BigDecimal creditsEarned,
        Boolean completed
) {
}

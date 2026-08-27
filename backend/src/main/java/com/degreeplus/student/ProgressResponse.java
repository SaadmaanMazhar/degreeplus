package com.degreeplus.student;

import java.math.BigDecimal;
import java.util.List;

public record ProgressResponse(
        BigDecimal currentCgpa,
        BigDecimal totalCreditsCompleted,
        Integer totalSemestersCompleted,
        List<CourseAttempt> history
) {
}

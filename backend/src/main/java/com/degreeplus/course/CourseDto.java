package com.degreeplus.course;

import java.math.BigDecimal;

public record CourseDto(
        String courseCode,
        String courseTitle,
        BigDecimal credits,
        BigDecimal minCreditsRequired,
        String departmentName
) {
}

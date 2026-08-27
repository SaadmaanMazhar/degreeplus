package com.degreeplus.student;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CourseAttemptRequest(
        @NotBlank String courseCode,
        @NotBlank String semesterName,
        Integer attemptNumber,
        @NotBlank String obtainedGrade,
        @NotNull @DecimalMin("0.0") @DecimalMax("4.0") BigDecimal gradePoint,
        @NotNull @DecimalMin("0.0") BigDecimal creditsEarned,
        Boolean completed
) {
}

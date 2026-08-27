package com.degreeplus.eligibility;

import java.math.BigDecimal;
import java.util.List;

public record EligibilityResponse(
        String courseCode,
        String courseTitle,
        boolean eligible,
        BigDecimal completedCredits,
        BigDecimal minCreditsRequired,
        List<String> missingPrerequisites,
        List<String> messages
) {
}

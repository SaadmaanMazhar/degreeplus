package com.degreeplus.eligibility;

import com.degreeplus.student.ProgressService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class EligibilityService {
    private final JdbcTemplate jdbcTemplate;
    private final ProgressService progressService;
    private final BigDecimal passingGradePoint;

    public EligibilityService(
            JdbcTemplate jdbcTemplate,
            ProgressService progressService,
            @Value("${degreeplus.academic.passing-grade-point}") BigDecimal passingGradePoint
    ) {
        this.jdbcTemplate = jdbcTemplate;
        this.progressService = progressService;
        this.passingGradePoint = passingGradePoint;
    }

    public EligibilityResponse checkEligibility(Long studentUserId, String courseCode) {
        CourseRuleTarget target = getCourse(courseCode);
        BigDecimal completedCredits = progressService.completedCredits(studentUserId);
        Set<String> passedCourses = passedCourses(studentUserId);
        Map<String, List<String>> prerequisiteMap = prerequisiteMap();

        LinkedHashSet<String> missing = new LinkedHashSet<>();
        collectMissingPrerequisites(courseCode, prerequisiteMap, passedCourses, missing, new HashSet<>());

        List<String> messages = new ArrayList<>();
        BigDecimal minCredits = target.minCreditsRequired() == null ? BigDecimal.ZERO : target.minCreditsRequired();
        if (completedCredits.compareTo(minCredits) < 0) {
            messages.add("Requires at least " + minCredits.stripTrailingZeros().toPlainString() + " completed credits.");
        }
        if (!missing.isEmpty()) {
            messages.add("Missing prerequisite courses: " + String.join(", ", missing) + ".");
        }
        if (messages.isEmpty()) {
            messages.add("Eligible for enrollment.");
        }

        return new EligibilityResponse(
                target.courseCode(),
                target.courseTitle(),
                missing.isEmpty() && completedCredits.compareTo(minCredits) >= 0,
                completedCredits,
                minCredits,
                List.copyOf(missing),
                messages
        );
    }

    public List<EligibilityResponse> checkAllCourses(Long studentUserId) {
        return jdbcTemplate.query("SELECT Course_Code AS course_code FROM COURSE ORDER BY Course_Code", (rs, rowNum) -> rs.getString("course_code"))
                .stream()
                .map(courseCode -> checkEligibility(studentUserId, courseCode))
                .collect(Collectors.toList());
    }

    private void collectMissingPrerequisites(
            String courseCode,
            Map<String, List<String>> prerequisiteMap,
            Set<String> passedCourses,
            LinkedHashSet<String> missing,
            Set<String> visited
    ) {
        if (!visited.add(courseCode)) {
            return;
        }

        for (String prerequisite : prerequisiteMap.getOrDefault(courseCode, List.of())) {
            if (!passedCourses.contains(prerequisite)) {
                missing.add(prerequisite);
            }
            collectMissingPrerequisites(prerequisite, prerequisiteMap, passedCourses, missing, visited);
        }
    }

    private CourseRuleTarget getCourse(String courseCode) {
        return jdbcTemplate.query("""
                SELECT Course_Code AS course_code,
                       Course_Title AS course_title,
                       Min_Credits_Required AS min_credits_required
                FROM COURSE
                WHERE Course_Code = ?
                """, (rs, rowNum) -> new CourseRuleTarget(
                rs.getString("course_code"),
                rs.getString("course_title"),
                rs.getBigDecimal("min_credits_required")
        ), courseCode).stream().findFirst().orElseThrow(() -> new NoSuchElementException("Course was not found."));
    }

    private Set<String> passedCourses(Long studentUserId) {
        return new HashSet<>(jdbcTemplate.query("""
                SELECT DISTINCT Course_Code AS course_code
                FROM TAKES
                WHERE User_ID = ?
                  AND Is_Completed = TRUE
                  AND Credits_Earned > 0
                  AND Grade_Point >= ?
                """, (rs, rowNum) -> rs.getString("course_code"), studentUserId, passingGradePoint));
    }

    private Map<String, List<String>> prerequisiteMap() {
        return jdbcTemplate.query("""
                SELECT Target AS target_course_code,
                       Prerequisite AS prerequisite_course_code
                FROM REQUIRES
                ORDER BY Target, Prerequisite
                """, rs -> {
            Map<String, List<String>> map = new java.util.LinkedHashMap<>();
            while (rs.next()) {
                map.computeIfAbsent(rs.getString("target_course_code"), key -> new ArrayList<>())
                        .add(rs.getString("prerequisite_course_code"));
            }
            return map;
        });
    }

    private record CourseRuleTarget(String courseCode, String courseTitle, BigDecimal minCreditsRequired) {
    }
}

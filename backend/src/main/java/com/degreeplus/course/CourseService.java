package com.degreeplus.course;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CourseService {
    private final JdbcTemplate jdbcTemplate;

    public CourseService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<CourseDto> allCourses() {
        return jdbcTemplate.query("""
                SELECT Course_Code AS course_code,
                       Course_Title AS course_title,
                       Credits AS credits,
                       Min_Credits_Required AS min_credits_required,
                       Department_Name AS department_name
                FROM COURSE
                ORDER BY Course_Code
                """, (rs, rowNum) -> new CourseDto(
                rs.getString("course_code"),
                rs.getString("course_title"),
                rs.getBigDecimal("credits"),
                rs.getBigDecimal("min_credits_required"),
                rs.getString("department_name")
        ));
    }
}

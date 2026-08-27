package com.degreeplus.auth;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class StudentAccountRepository {
    private final JdbcTemplate jdbcTemplate;

    public StudentAccountRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void createStudent(Long userId, String departmentName) {
        jdbcTemplate.update("""
                INSERT INTO STUDENT (
                    User_ID,
                    Department_Name,
                    Consecutive_Probation_Count,
                    Academic_Status,
                    Current_Risk_Level,
                    Advisor_id
                )
                VALUES (?, ?, 0, 'GOOD_STANDING', 'NONE', NULL)
                """, userId, departmentName);
    }
}

package com.degreeplus.auth;

import com.degreeplus.common.Role;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.Optional;

@Repository
public class UserRepository {
    private final JdbcTemplate jdbcTemplate;

    private final RowMapper<UserAccount> mapper = (rs, rowNum) -> new UserAccount(
            rs.getLong("user_id"),
            rs.getString("full_name"),
            rs.getString("email"),
            rs.getString("password_hash"),
            Role.valueOf(rs.getString("role"))
    );

    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Optional<UserAccount> findByEmail(String email) {
        return jdbcTemplate.query("""
                SELECT u.User_ID AS user_id,
                       u.Full_Name AS full_name,
                       u.Email AS email,
                       u.Password_Hash AS password_hash,
                       CASE
                           WHEN s.User_ID IS NOT NULL THEN 'STUDENT'
                           WHEN adv.User_ID IS NOT NULL THEN 'ADVISOR'
                           WHEN adm.User_ID IS NOT NULL THEN 'ADMIN'
                           WHEN f.User_ID IS NOT NULL THEN 'FACULTY'
                       END AS role
                FROM `USER` u
                LEFT JOIN STUDENT s ON s.User_ID = u.User_ID
                LEFT JOIN ADVISOR adv ON adv.User_ID = u.User_ID
                LEFT JOIN ADMIN adm ON adm.User_ID = u.User_ID
                LEFT JOIN FACULTY f ON f.User_ID = u.User_ID
                WHERE u.Email = ?
                """, mapper, email).stream().findFirst();
    }

    public Optional<UserAccount> findById(Long userId) {
        return jdbcTemplate.query("""
                SELECT u.User_ID AS user_id,
                       u.Full_Name AS full_name,
                       u.Email AS email,
                       u.Password_Hash AS password_hash,
                       CASE
                           WHEN s.User_ID IS NOT NULL THEN 'STUDENT'
                           WHEN adv.User_ID IS NOT NULL THEN 'ADVISOR'
                           WHEN adm.User_ID IS NOT NULL THEN 'ADMIN'
                           WHEN f.User_ID IS NOT NULL THEN 'FACULTY'
                       END AS role
                FROM `USER` u
                LEFT JOIN STUDENT s ON s.User_ID = u.User_ID
                LEFT JOIN ADVISOR adv ON adv.User_ID = u.User_ID
                LEFT JOIN ADMIN adm ON adm.User_ID = u.User_ID
                LEFT JOIN FACULTY f ON f.User_ID = u.User_ID
                WHERE u.User_ID = ?
                """, mapper, userId).stream().findFirst();
    }

    public Long createUser(String fullName, String email, String passwordHash, Role role) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement("""
                    INSERT INTO `USER` (Full_Name, Email, Password_Hash)
                    VALUES (?, ?, ?)
                    """, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, passwordHash);
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }
}

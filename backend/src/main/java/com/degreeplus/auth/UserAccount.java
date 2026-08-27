package com.degreeplus.auth;

import com.degreeplus.common.Role;

public record UserAccount(
        Long userId,
        String fullName,
        String email,
        String passwordHash,
        Role role
) {
}

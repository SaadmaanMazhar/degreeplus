package com.degreeplus.auth;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

public class UserPrincipal implements UserDetails {
    private final UserAccount account;

    public UserPrincipal(UserAccount account) {
        this.account = account;
    }

    public Long userId() {
        return account.userId();
    }

    public String fullName() {
        return account.fullName();
    }

    public String role() {
        return account.role().name();
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + account.role().name()));
    }

    @Override
    public String getPassword() {
        return account.passwordHash();
    }

    @Override
    public String getUsername() {
        return account.email();
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return true;
    }
}

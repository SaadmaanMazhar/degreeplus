package com.degreeplus.auth;

import com.degreeplus.common.Role;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final StudentAccountRepository studentAccountRepository;

    public AuthController(
            UserRepository userRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            StudentAccountRepository studentAccountRepository
    ) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.studentAccountRepository = studentAccountRepository;
    }

    @PostMapping("/login")
    AuthResponse login(@Valid @RequestBody LoginRequest request) {
        UserAccount account = userRepository.findByEmail(request.email())
                .filter(user -> passwordEncoder.matches(request.password(), user.passwordHash()))
                .orElseThrow(() -> new BadCredentialsException("Invalid credentials."));

        return new AuthResponse(
                jwtService.createToken(account),
                account.userId(),
                account.fullName(),
                account.email(),
                account.role().name()
        );
    }

    @PostMapping("/register/student")
    AuthResponse registerStudent(@Valid @RequestBody RegisterStudentRequest request) {
        userRepository.findByEmail(request.email()).ifPresent(user -> {
            throw new IllegalArgumentException("Email is already registered.");
        });

        Long userId = userRepository.createUser(
                request.fullName(),
                request.email(),
                passwordEncoder.encode(request.password()),
                Role.STUDENT
        );
        studentAccountRepository.createStudent(userId, request.departmentName());
        UserAccount account = userRepository.findById(userId).orElseThrow();
        return new AuthResponse(
                jwtService.createToken(account),
                account.userId(),
                account.fullName(),
                account.email(),
                account.role().name()
        );
    }

    public record LoginRequest(@NotBlank @Email String email, @NotBlank String password) {
    }

    public record RegisterStudentRequest(
            @NotBlank String fullName,
            @NotBlank @Email String email,
            @NotBlank String password,
            @NotBlank String departmentName
    ) {
    }

    public record AuthResponse(String token, Long userId, String fullName, String email, String role) {
    }
}

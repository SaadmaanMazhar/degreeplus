package com.degreeplus.student;

import com.degreeplus.auth.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/students/me")
@PreAuthorize("hasRole('STUDENT')")
public class ProgressController {
    private final ProgressService progressService;

    public ProgressController(ProgressService progressService) {
        this.progressService = progressService;
    }

    @GetMapping("/progress")
    ProgressResponse progress(@AuthenticationPrincipal UserPrincipal principal) {
        return progressService.getProgress(principal.userId());
    }

    @PostMapping("/course-attempts")
    ProgressResponse addAttempt(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody CourseAttemptRequest request
    ) {
        progressService.addAttempt(principal.userId(), request);
        return progressService.getProgress(principal.userId());
    }
}

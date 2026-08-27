package com.degreeplus.eligibility;

import com.degreeplus.auth.UserPrincipal;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/eligibility")
@PreAuthorize("hasRole('STUDENT')")
public class EligibilityController {
    private final EligibilityService eligibilityService;

    public EligibilityController(EligibilityService eligibilityService) {
        this.eligibilityService = eligibilityService;
    }

    @GetMapping("/courses")
    List<EligibilityResponse> all(@AuthenticationPrincipal UserPrincipal principal) {
        return eligibilityService.checkAllCourses(principal.userId());
    }

    @GetMapping("/courses/{courseCode}")
    EligibilityResponse one(@AuthenticationPrincipal UserPrincipal principal, @PathVariable String courseCode) {
        return eligibilityService.checkEligibility(principal.userId(), courseCode);
    }
}

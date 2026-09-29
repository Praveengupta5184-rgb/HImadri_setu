package in.gov.moes.ncpor.polarops.controller;
import in.gov.moes.ncpor.polarops.dto.*;
import in.gov.moes.ncpor.polarops.service.UserService;
import in.gov.moes.ncpor.polarops.model.User;
import in.gov.moes.ncpor.polarops.model.Role;
import in.gov.moes.ncpor.polarops.model.UserStatus;
import in.gov.moes.ncpor.polarops.security.JwtUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    private final UserService userService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;

    private static final Set<Role> PRIVILEGED_ROLES = Set.of(
        Role.ADMIN, Role.MISSION_OFFICER, Role.STATION_OFFICER,
        Role.LOGISTICS_OFFICER, Role.ASSET_OFFICER, Role.FIELD_OPERATOR,
        Role.MEDICAL_OFFICER
    );

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody AuthRequest request) {
        Optional<User> userOpt = userService.findByEmail(request.getEmail());
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            UserStatus status = user.getStatus() != null ? user.getStatus() : UserStatus.ACTIVE;
            if (status != UserStatus.ACTIVE) {
                return ResponseEntity.status(403).body(Map.of(
                    "error", "ACCOUNT_NOT_ACTIVE",
                    "message", "Account is pending approval or rejected. Contact an administrator."
                ));
            }
            if (passwordEncoder.matches(request.getPassword(), user.getPassword())) {
                String token = jwtUtil.generateToken(user.getEmail(), user.getRole().name());
                return ResponseEntity.ok(new AuthResponse(token, user.getRole().name(),
                        user.getId(), user.getName(), user.getEmail()));
            }
        }
        return ResponseEntity.status(401).body(Map.of(
            "error", "INVALID_CREDENTIALS",
            "message", "Invalid email or password."
        ));
    }

    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        try {
            if (request.getEmail() == null || request.getPassword() == null || request.getName() == null) {
                return ResponseEntity.badRequest().body(Map.of(
                    "error", "VALIDATION_ERROR",
                    "message", "Email, password, and name are required."
                ));
            }
            if (request.getPassword().length() < 6) {
                return ResponseEntity.badRequest().body(Map.of(
                    "error", "VALIDATION_ERROR",
                    "message", "Password must be at least 6 characters."
                ));
            }
            if (request.getRole() != null && PRIVILEGED_ROLES.contains(request.getRole())) {
                return ResponseEntity.badRequest().body(Map.of(
                    "error", "INVALID_ROLE",
                    "message", "Privileged roles cannot be self-assigned during registration."
                ));
            }
            User user = userService.register(request.getEmail(), request.getPassword(), request.getName());
            return ResponseEntity.status(201).body(Map.of(
                "id", user.getId(),
                "email", user.getEmail(),
                "name", user.getName(),
                "role", user.getRole().name(),
                "status", user.getStatus().name(),
                "message", "Registration successful. Account pending administrator approval."
            ));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of(
                "error", "VALIDATION_ERROR",
                "message", e.getMessage()
            ));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<?> me(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).build();
        }
        Optional<User> userOpt = userService.findByEmail(authentication.getName());
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            return ResponseEntity.ok(new AuthResponse(
                null, user.getRole().name(),
                user.getId(), user.getName(), user.getEmail()
            ));
        }
        return ResponseEntity.status(401).build();
    }

    @GetMapping("/users")
    public ResponseEntity<?> listUsers(Authentication a) {
        if (!isAdmin(a)) return ResponseEntity.status(403).build();
        List<Map<String, Object>> result = userService.findAll().stream()
            .map(u -> {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", u.getId());
                m.put("email", u.getEmail());
                m.put("name", u.getName());
                m.put("role", u.getRole().name());
                m.put("status", u.getStatus().name());
                return m;
            })
            .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @GetMapping("/users/pending")
    public ResponseEntity<?> listPending(Authentication a) {
        if (!isAdmin(a)) return ResponseEntity.status(403).build();
        List<Map<String, Object>> result = userService.findPending().stream()
            .map(u -> {
                Map<String, Object> m = new LinkedHashMap<>();
                m.put("id", u.getId());
                m.put("email", u.getEmail());
                m.put("name", u.getName());
                m.put("role", u.getRole().name());
                m.put("status", u.getStatus().name());
                return m;
            })
            .collect(Collectors.toList());
        return ResponseEntity.ok(result);
    }

    @PutMapping("/users/{userId}/approve")
    public ResponseEntity<?> approveUser(@PathVariable Long userId, Authentication a) {
        if (!isAdmin(a)) return ResponseEntity.status(403).build();
        try {
            User user = userService.approve(userId, a.getName());
            return ResponseEntity.ok(Map.of(
                "id", user.getId(),
                "email", user.getEmail(),
                "status", user.getStatus().name()
            ));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/users/{userId}/reject")
    public ResponseEntity<?> rejectUser(@PathVariable Long userId, Authentication a) {
        if (!isAdmin(a)) return ResponseEntity.status(403).build();
        try {
            User user = userService.reject(userId, a.getName());
            return ResponseEntity.ok(Map.of(
                "id", user.getId(),
                "email", user.getEmail(),
                "status", user.getStatus().name()
            ));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/users/{userId}/role")
    public ResponseEntity<?> assignRole(@PathVariable Long userId, @RequestBody RoleAssignmentRequest request, Authentication a) {
        if (!isAdmin(a)) return ResponseEntity.status(403).build();
        if (request.getRole() == null) return ResponseEntity.badRequest().body(Map.of("message", "Role is required"));
        if (userId.equals(getCurrentUserId(a))) {
            return ResponseEntity.status(403).body(Map.of("message", "Users cannot modify their own role"));
        }
        try {
            User user = userService.assignRole(userId, request.getRole(), a.getName());
            return ResponseEntity.ok(Map.of(
                "id", user.getId(),
                "email", user.getEmail(),
                "role", user.getRole().name(),
                "status", user.getStatus().name()
            ));
        } catch (NoSuchElementException e) {
            return ResponseEntity.notFound().build();
        }
    }

    private boolean isAdmin(Authentication a) {
        if (a == null) return false;
        return a.getAuthorities().stream().anyMatch(x -> x.getAuthority().equals("ROLE_ADMIN"));
    }

    private Long getCurrentUserId(Authentication a) {
        Optional<User> userOpt = userService.findByEmail(a.getName());
        return userOpt.map(User::getId).orElse(-1L);
    }
}

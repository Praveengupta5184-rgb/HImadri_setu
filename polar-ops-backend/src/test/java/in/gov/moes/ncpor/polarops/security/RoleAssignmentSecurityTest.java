package in.gov.moes.ncpor.polarops.security;

import in.gov.moes.ncpor.polarops.model.AuditLog;
import in.gov.moes.ncpor.polarops.model.Role;
import in.gov.moes.ncpor.polarops.model.User;
import in.gov.moes.ncpor.polarops.model.UserStatus;
import in.gov.moes.ncpor.polarops.repository.UserRepository;
import in.gov.moes.ncpor.polarops.service.AuditService;
import in.gov.moes.ncpor.polarops.service.UserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.*;

class RoleAssignmentSecurityTest {

    private UserRepository userRepository;
    private PasswordEncoder passwordEncoder;
    private AuditService auditService;
    private UserService userService;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        passwordEncoder = mock(PasswordEncoder.class);
        auditService = new AuditService();
        userService = new UserService(userRepository, passwordEncoder, auditService);
        when(passwordEncoder.encode(anyString())).thenAnswer(inv -> "hashed_" + inv.getArgument(0));
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
    }

    @Test
    void adminCanApprovePendingUser() {
        User pending = User.builder()
                .id(1L).email("pending@test.com").password("hash")
                .role(Role.PERSONNEL).status(UserStatus.PENDING)
                .build();
        when(userRepository.findById(1L)).thenReturn(Optional.of(pending));

        User approved = userService.approve(1L, "admin@polarops.gov.in");
        assertThat(approved.getStatus()).isEqualTo(UserStatus.ACTIVE);
        List<AuditLog> logs = auditService.getLogs();
        assertThat(logs).anyMatch(l -> l.getAction().equals("USER_APPROVED"));
    }

    @Test
    void adminCannotAssignRoleToSelf() {
        Long adminId = 5L;
        User admin = User.builder()
                .id(adminId).email("admin@polarops.gov.in").password("hash")
                .role(Role.ADMIN).status(UserStatus.ACTIVE).name("Admin")
                .build();
        when(userRepository.findById(adminId)).thenReturn(Optional.of(admin));

        assertThatThrownBy(() -> userService.assignRole(adminId, Role.PERSONNEL, "admin@polarops.gov.in"))
                .hasMessageContaining("cannot modify their own role");
    }

    @Test
    void adminCanAssignRoleToOtherUser() {
        Long targetId = 2L;
        User target = User.builder()
                .id(targetId).email("target@test.com").password("hash")
                .role(Role.PERSONNEL).status(UserStatus.ACTIVE).name("Target")
                .build();
        when(userRepository.findById(targetId)).thenReturn(Optional.of(target));

        User updated = userService.assignRole(targetId, Role.MISSION_OFFICER, "admin@polarops.gov.in");
        assertThat(updated.getRole()).isEqualTo(Role.MISSION_OFFICER);
    }

    @Test
    void assignRoleAuditsTheAction() {
        User target = User.builder()
                .id(2L).email("target@test.com").password("hash")
                .role(Role.PERSONNEL).status(UserStatus.ACTIVE).name("Target")
                .build();
        when(userRepository.findById(2L)).thenReturn(Optional.of(target));

        userService.assignRole(2L, Role.MISSION_OFFICER, "admin@polarops.gov.in");

        List<AuditLog> logs = auditService.getLogs();
        assertThat(logs).anyMatch(l ->
                l.getAction().equals("ROLE_ASSIGNED") &&
                l.getUser().equals("admin@polarops.gov.in")
        );
    }

    @Test
    void approveAuditsTheAction() {
        User pending = User.builder()
                .id(1L).email("pending@test.com").password("hash")
                .role(Role.PERSONNEL).status(UserStatus.PENDING)
                .build();
        when(userRepository.findById(1L)).thenReturn(Optional.of(pending));

        userService.approve(1L, "admin@polarops.gov.in");

        List<AuditLog> logs = auditService.getLogs();
        assertThat(logs).anyMatch(l ->
                l.getAction().equals("USER_APPROVED") &&
                l.getUser().equals("admin@polarops.gov.in") &&
                l.getEntity().equals("pending@test.com")
        );
    }

    @Test
    void rejectAuditsTheAction() {
        User pending = User.builder()
                .id(1L).email("pending@test.com").password("hash")
                .role(Role.PERSONNEL).status(UserStatus.PENDING)
                .build();
        when(userRepository.findById(1L)).thenReturn(Optional.of(pending));

        User rejected = userService.reject(1L, "admin@polarops.gov.in");
        assertThat(rejected.getStatus()).isEqualTo(UserStatus.REJECTED);

        List<AuditLog> logs = auditService.getLogs();
        assertThat(logs).anyMatch(l -> l.getAction().equals("USER_REJECTED"));
    }
}

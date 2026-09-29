package in.gov.moes.ncpor.polarops.security;

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
import static org.mockito.Mockito.*;

class RegistrationSecurityTest {

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
        when(userRepository.count()).thenReturn(1L);
        when(userRepository.findByEmail(anyString())).thenReturn(Optional.empty());
        when(userRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
    }

    @Test
    void publicRegistrationCreatesOnlyPersonnel() {
        User user = userService.register("new@test.com", "password123", "New User");
        assertThat(user.getRole()).isEqualTo(Role.PERSONNEL);
        assertThat(user.getStatus()).isEqualTo(UserStatus.PENDING);
        assertThat(user.getEmail()).isEqualTo("new@test.com");
        verify(userRepository).save(user);
    }

    @Test
    void publicRegistrationCannotCreateAdmin() {
        User user = userService.register("admin1@test.com", "password123", "Admin Wannabe");
        assertThat(user.getRole()).isEqualTo(Role.PERSONNEL);
        assertThat(user.getRole()).isNotEqualTo(Role.ADMIN);
    }

    @Test
    void publicRegistrationCannotCreateMissionOfficer() {
        User user = userService.register("officer@test.com", "password123", "Officer Wannabe");
        assertThat(user.getRole()).isEqualTo(Role.PERSONNEL);
        assertThat(user.getRole()).isNotEqualTo(Role.MISSION_OFFICER);
    }

    @Test
    void publicRegistrationCannotCreateStationOfficer() {
        User user = userService.register("station@test.com", "password123", "Station Wannabe");
        assertThat(user.getRole()).isEqualTo(Role.PERSONNEL);
        assertThat(user.getRole()).isNotEqualTo(Role.STATION_OFFICER);
    }

    @Test
    void publicRegistrationCannotCreateLogisticsOfficer() {
        User user = userService.register("logistics@test.com", "password123", "Logistics Wannabe");
        assertThat(user.getRole()).isEqualTo(Role.PERSONNEL);
        assertThat(user.getRole()).isNotEqualTo(Role.LOGISTICS_OFFICER);
    }

    @Test
    void publicRegistrationCannotCreateAssetOfficer() {
        User user = userService.register("asset@test.com", "password123", "Asset Wannabe");
        assertThat(user.getRole()).isEqualTo(Role.PERSONNEL);
        assertThat(user.getRole()).isNotEqualTo(Role.ASSET_OFFICER);
    }

    @Test
    void publicRegistrationCannotCreateMedicalOfficer() {
        User user = userService.register("medical@test.com", "password123", "Medical Wannabe");
        assertThat(user.getRole()).isEqualTo(Role.PERSONNEL);
        assertThat(user.getRole()).isNotEqualTo(Role.MEDICAL_OFFICER);
    }

    @Test
    void publicRegistrationCannotCreateFieldOperator() {
        User user = userService.register("field@test.com", "password123", "Field Wannabe");
        assertThat(user.getRole()).isEqualTo(Role.PERSONNEL);
        assertThat(user.getRole()).isNotEqualTo(Role.FIELD_OPERATOR);
    }

    @Test
    void registrationEntersPendingStatus() {
        User user = userService.register("pending@test.com", "password123", "Pending User");
        assertThat(user.getStatus()).isEqualTo(UserStatus.PENDING);
    }

    @Test
    void pendingUserCannotAuthenticate() {
        User pendingUser = User.builder()
                .id(1L).email("pending@test.com").password("hash")
                .role(Role.PERSONNEL).status(UserStatus.PENDING)
                .build();
        assertThat(userService.canAuthenticate(pendingUser)).isFalse();
    }

    @Test
    void activeUserCanAuthenticate() {
        User activeUser = User.builder()
                .id(1L).email("active@test.com").password("hash")
                .role(Role.PERSONNEL).status(UserStatus.ACTIVE)
                .build();
        assertThat(userService.canAuthenticate(activeUser)).isTrue();
    }

    @Test
    void rejectedUserCannotAuthenticate() {
        User rejectedUser = User.builder()
                .id(1L).email("rejected@test.com").password("hash")
                .role(Role.PERSONNEL).status(UserStatus.REJECTED)
                .build();
        assertThat(userService.canAuthenticate(rejectedUser)).isFalse();
    }
}

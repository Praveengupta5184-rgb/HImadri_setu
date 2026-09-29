package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.User;
import in.gov.moes.ncpor.polarops.model.Role;
import in.gov.moes.ncpor.polarops.model.UserStatus;
import in.gov.moes.ncpor.polarops.repository.UserRepository;
import in.gov.moes.ncpor.polarops.service.AuditService;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuditService audit;

    @PostConstruct
    public void initUsers() {
        if (userRepository.count() == 0) {
            userRepository.save(User.builder().email("admin@polarops.gov.in").password(passwordEncoder.encode("password")).role(Role.ADMIN).status(UserStatus.ACTIVE).name("System Administrator").build());
            userRepository.save(User.builder().email("logistics@polarops.gov.in").password(passwordEncoder.encode("password")).role(Role.LOGISTICS_OFFICER).status(UserStatus.ACTIVE).name("Logistics Officer").build());
            userRepository.save(User.builder().email("field@polarops.gov.in").password(passwordEncoder.encode("password")).role(Role.FIELD_OPERATOR).status(UserStatus.ACTIVE).name("Field Operator").build());
            userRepository.save(User.builder().email("station@polarops.gov.in").password(passwordEncoder.encode("password")).role(Role.STATION_OFFICER).status(UserStatus.ACTIVE).name("Station Commander").build());
        } else {
            List<User> all = userRepository.findAll();
            boolean needsMigration = all.stream().anyMatch(u -> !u.getPassword().startsWith("$2"));
            if (needsMigration) {
                for (User u : all) {
                    if (!u.getPassword().startsWith("$2")) {
                        u.setPassword(passwordEncoder.encode(u.getPassword()));
                        u.setStatus(UserStatus.ACTIVE);
                    } else if (u.getStatus() == null) {
                        u.setStatus(UserStatus.ACTIVE);
                    }
                }
                userRepository.saveAll(all);
            } else {
                for (User u : all) {
                    if (u.getStatus() == null) {
                        u.setStatus(UserStatus.ACTIVE);
                    }
                }
                userRepository.saveAll(all);
            }
        }
    }

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public User register(String email, String password, String name) {
        if (userRepository.findByEmail(email).isPresent()) {
            throw new IllegalArgumentException("Email already registered");
        }
        User user = User.builder()
                .email(email)
                .password(passwordEncoder.encode(password))
                .name(name)
                .role(Role.PERSONNEL)
                .status(UserStatus.PENDING)
                .build();
        User saved = userRepository.save(user);
        audit.logAction("SYSTEM", "USER_REGISTERED", email);
        return saved;
    }

    public User approve(Long userId, String approverEmail) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("User not found"));
        user.setStatus(UserStatus.ACTIVE);
        User saved = userRepository.save(user);
        audit.logAction(approverEmail, "USER_APPROVED", user.getEmail());
        return saved;
    }

    public User reject(Long userId, String rejectorEmail) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("User not found"));
        user.setStatus(UserStatus.REJECTED);
        User saved = userRepository.save(user);
        audit.logAction(rejectorEmail, "USER_REJECTED", user.getEmail());
        return saved;
    }

    public User assignRole(Long userId, Role newRole, String assignerEmail) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new NoSuchElementException("User not found"));
        user.setRole(newRole);
        User saved = userRepository.save(user);
        audit.logAction(assignerEmail, "ROLE_ASSIGNED", user.getEmail() + ":" + newRole.name());
        return saved;
    }

    public List<User> findPending() {
        return userRepository.findAll().stream()
                .filter(u -> u.getStatus() == UserStatus.PENDING)
                .collect(Collectors.toList());
    }

    public boolean canAuthenticate(User user) {
        return user.getStatus() == UserStatus.ACTIVE;
    }
}

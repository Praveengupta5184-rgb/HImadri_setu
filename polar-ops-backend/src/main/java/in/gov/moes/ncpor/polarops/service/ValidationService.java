package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.model.User;
import in.gov.moes.ncpor.polarops.model.UserStatus;
import in.gov.moes.ncpor.polarops.repository.InventoryRepository;
import in.gov.moes.ncpor.polarops.repository.PersonnelRepository;
import in.gov.moes.ncpor.polarops.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ValidationService {

    private final UserRepository userRepository;
    private final PersonnelRepository personnelRepository;
    private final InventoryRepository inventoryRepository;

    public record ValidationResult(boolean valid, String errorCode, String message) {
        public static ValidationResult success() {
            return new ValidationResult(true, null, null);
        }
        
        public static ValidationResult userNotFound() {
            return new ValidationResult(false, "USER_NOT_FOUND", "User not found");
        }
        
        public static ValidationResult personnelNotFound() {
            return new ValidationResult(false, "PERSONNEL_NOT_FOUND", "Personnel not found");
        }
        
        public static ValidationResult inventoryItemNotFound() {
            return new ValidationResult(false, "INVENTORY_ITEM_NOT_FOUND", "Inventory item not found");
        }
        
        public static ValidationResult userNotActive() {
            return new ValidationResult(false, "USER_NOT_ACTIVE", "User account is not active");
        }
        
        public static ValidationResult userPending() {
            return new ValidationResult(false, "USER_PENDING_APPROVAL", "User account is pending approval");
        }
        
        public static ValidationResult userRejected() {
            return new ValidationResult(false, "USER_REJECTED", "User account has been rejected");
        }
        
        public static ValidationResult personnelNotLinkedToUser() {
            return new ValidationResult(false, "PERSONNEL_USER_MISMATCH", "Personnel record not linked to user account");
        }
        
        public static ValidationResult invalidStatus(String status) {
            return new ValidationResult(false, "INVALID_USER_STATUS", "User account status invalid: " + status);
        }
    }

    public ValidationResult validateUserExists(Long userId) {
        if (userId == null) {
            return ValidationResult.userNotFound();
        }
        Optional<User> user = userRepository.findById(userId);
        if (user.isEmpty()) {
            return ValidationResult.userNotFound();
        }
        return ValidationResult.success();
    }

    public ValidationResult validatePersonnelExists(Long personnelId) {
        if (personnelId == null) {
            return ValidationResult.personnelNotFound();
        }
        Optional<Personnel> personnel = personnelRepository.findById(personnelId);
        if (personnel.isEmpty()) {
            return ValidationResult.personnelNotFound();
        }
        return ValidationResult.success();
    }

    public ValidationResult validateInventoryItemExists(Long inventoryItemId) {
        if (inventoryItemId == null) {
            return ValidationResult.inventoryItemNotFound();
        }
        Optional<InventoryItem> item = inventoryRepository.findById(inventoryItemId);
        if (item.isEmpty()) {
            return ValidationResult.inventoryItemNotFound();
        }
        return ValidationResult.success();
    }

    public ValidationResult validateUserActive(Long userId) {
        ValidationResult exists = validateUserExists(userId);
        if (!exists.valid()) {
            return exists;
        }
        
        User user = userRepository.findById(userId).get();
        UserStatus status = user.getStatus() != null ? user.getStatus() : UserStatus.ACTIVE;
        
        if (status != UserStatus.ACTIVE) {
            return switch (status) {
                case PENDING -> ValidationResult.userPending();
                case REJECTED -> ValidationResult.userRejected();
                default -> ValidationResult.invalidStatus(status.name());
            };
        }
        return ValidationResult.success();
    }

    public ValidationResult validatePersonnelLinkedToUser(Long personnelId, Long userId) {
        ValidationResult personnelExists = validatePersonnelExists(personnelId);
        if (!personnelExists.valid()) {
            return personnelExists;
        }
        
        ValidationResult userExists = validateUserExists(userId);
        if (!userExists.valid()) {
            return userExists;
        }
        
        User user = userRepository.findById(userId).get();
        if (user.getPersonnel() == null || !user.getPersonnel().getId().equals(personnelId)) {
            return ValidationResult.personnelNotLinkedToUser();
        }
        
        return ValidationResult.success();
    }

    public ValidationResult validateUserOrPersonnelExists(Long userId, Long personnelId) {
        if (userId != null) {
            return validateUserExists(userId);
        } else if (personnelId != null) {
            return validatePersonnelExists(personnelId);
        }
        return new ValidationResult(false, "MISSING_REFERENCE", "Either userId or personnelId must be provided");
    }

    public Optional<User> findUser(Long userId) {
        return userRepository.findById(userId);
    }

    public Optional<Personnel> findPersonnel(Long personnelId) {
        return personnelRepository.findById(personnelId);
    }

    public Optional<InventoryItem> findInventoryItem(Long inventoryItemId) {
        return inventoryRepository.findById(inventoryItemId);
    }

    public boolean isUserActive(Long userId) {
        return userRepository.findById(userId)
                .map(u -> u.getStatus() == UserStatus.ACTIVE)
                .orElse(false);
    }
}
package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.dto.KitIssueRequest;
import in.gov.moes.ncpor.polarops.model.*;
import in.gov.moes.ncpor.polarops.repository.*;
import in.gov.moes.ncpor.polarops.service.ValidationService.ValidationResult;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PersonnelKitService {
    private final PersonnelRepository personnelRepository;
    private final InventoryRepository inventoryRepository;
    private final PersonnelKitRepository kitRepository;
    private final InventoryTransactionRepository transactionRepository;
    private final ValidationService validationService;

    public List<PersonnelKit> getForPersonnel(Long personnelId) {
        return kitRepository.findByPersonnelId(personnelId);
    }

    @Transactional
    public PersonnelKit issue(Long personnelId, KitIssueRequest request, String operator) {
        ValidationResult personnelValidation = validationService.validatePersonnelExists(personnelId);
        if (!personnelValidation.valid()) {
            throw new IllegalArgumentException("Personnel not found");
        }

        Personnel personnel = personnelRepository.findById(personnelId).orElseThrow();
        
        if (request.getQuantity() == null || request.getQuantity() <= 0) {
            throw new IllegalArgumentException("Quantity must be greater than zero");
        }
        
        InventoryItem item = null;
        if (request.getInventoryItemId() != null) {
            ValidationResult itemValidation = validationService.validateInventoryItemExists(request.getInventoryItemId());
            if (!itemValidation.valid()) {
                throw new IllegalArgumentException("Inventory item not found");
            }
            item = inventoryRepository.findById(request.getInventoryItemId())
                    .orElseThrow(() -> new IllegalArgumentException("Inventory item not found"));
        }
        
        if (item != null) {
            int available = item.getQuantityAvailable() == null ? 0 : item.getQuantityAvailable();
            if (available < request.getQuantity()) {
                throw new IllegalStateException("Insufficient available stock");
            }
            item.setQuantityAvailable(available - request.getQuantity());
            inventoryRepository.save(item);
            transactionRepository.save(InventoryTransaction.builder()
                    .inventoryItem(item)
                    .transactionType("ISSUED")
                    .quantity(-request.getQuantity())
                    .source(item.getStation())
                    .destination(personnel.getName())
                    .performedBy(operator)
                    .occurredAt(LocalDateTime.now())
                    .reference("PERSONNEL_KIT")
                    .notes(request.getNotes())
                    .build());
        }
        
        return kitRepository.save(PersonnelKit.builder()
                .personnel(personnel)
                .inventoryItem(item)
                .itemName(item != null ? item.getName() : request.getItemName())
                .category(item != null ? item.getCategory() : request.getCategory())
                .quantity(request.getQuantity())
                .unit(item != null ? item.getUnit() : request.getUnit())
                .issueDate(LocalDate.now())
                .expectedReturnDate(request.getExpectedReturnDate())
                .returnStatus("ISSUED")
                .issuedBy(operator)
                .notes(request.getNotes())
                .build());
    }
}
package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.repository.InventoryRepository;
import in.gov.moes.ncpor.polarops.repository.InventoryTransactionRepository;
import in.gov.moes.ncpor.polarops.model.InventoryTransaction;
import in.gov.moes.ncpor.polarops.dto.InventoryAdjustmentRequest;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InventoryService {
    private final InventoryRepository inventoryRepository;
    private final InventoryTransactionRepository transactionRepository;

    public List<InventoryItem> getAll() {
        return inventoryRepository.findAll();
    }

    public InventoryItem getById(Long id) {
        return inventoryRepository.findById(id).orElse(null);
    }

    public InventoryItem save(InventoryItem item) {
        return inventoryRepository.save(item);
    }

    public void delete(Long id) {
        inventoryRepository.deleteById(id);
    }

    public List<InventoryTransaction> getTransactions(Long itemId) {
        return transactionRepository.findByInventoryItemItemIdOrderByOccurredAtDesc(itemId);
    }

    @Transactional
    public InventoryItem adjust(Long itemId, InventoryAdjustmentRequest request, String operator) {
        InventoryItem item = getById(itemId);
        if (item == null) throw new IllegalArgumentException("Inventory item not found");
        if (request.getQuantity() == null || request.getQuantity() <= 0) throw new IllegalArgumentException("Quantity must be greater than zero");
        String type = request.getTransactionType();
        if (!List.of("RECEIVED", "ISSUED", "CONSUMED", "TRANSFERRED", "ADJUSTED", "EXPIRED").contains(type)) {
            throw new IllegalArgumentException("Unsupported inventory transaction type");
        }
        boolean reducesStock = List.of("ISSUED", "CONSUMED", "TRANSFERRED", "EXPIRED").contains(type);
        int delta = reducesStock ? -request.getQuantity() : request.getQuantity();
        int available = item.getQuantityAvailable() == null ? 0 : item.getQuantityAvailable();
        if (available + delta < 0) throw new IllegalStateException("Insufficient available stock");
        item.setQuantityAvailable(available + delta);
        item = inventoryRepository.save(item);
        transactionRepository.save(InventoryTransaction.builder()
                .inventoryItem(item).transactionType(type).quantity(delta).source(item.getStation())
                .destination(request.getDestination()).performedBy(operator)
                .occurredAt(java.time.LocalDateTime.now()).reference(request.getReference()).notes(request.getNotes()).build());
        return item;
    }
}

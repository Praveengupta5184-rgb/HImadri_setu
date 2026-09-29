package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.InventoryTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface InventoryTransactionRepository extends JpaRepository<InventoryTransaction, Long> {
    List<InventoryTransaction> findByInventoryItemItemIdOrderByOccurredAtDesc(Long itemId);
}

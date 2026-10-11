package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.InventoryConsumptionHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface InventoryConsumptionHistoryRepository extends JpaRepository<InventoryConsumptionHistory, Long> {
    List<InventoryConsumptionHistory> findByInventoryItemItemId(Long itemId);
    List<InventoryConsumptionHistory> findByInventoryItemItemIdOrderByConsumptionDateDesc(Long itemId);
}
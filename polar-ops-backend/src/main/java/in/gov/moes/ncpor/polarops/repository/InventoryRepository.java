package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.InventoryItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface InventoryRepository extends JpaRepository<InventoryItem, Long> {
    List<InventoryItem> findByLocation(String location);

}

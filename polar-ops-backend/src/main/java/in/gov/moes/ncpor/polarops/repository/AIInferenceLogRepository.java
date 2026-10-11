package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.AIInferenceLog;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AIInferenceLogRepository extends JpaRepository<AIInferenceLog, Long> {
    List<AIInferenceLog> findByMissionId(Long missionId);
    List<AIInferenceLog> findByCargoId(Long cargoId);
    List<AIInferenceLog> findByInventoryItemId(Long inventoryItemId);
    List<AIInferenceLog> findByCreatedAtAfter(java.time.LocalDateTime after);
}
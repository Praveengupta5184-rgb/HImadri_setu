package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.AnomalyEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AnomalyEventRepository extends JpaRepository<AnomalyEvent, Long> {
    List<AnomalyEvent> findByEntityTypeAndEntityId(String entityType, Long entityId);
    List<AnomalyEvent> findByDetectedAtAfter(java.time.LocalDateTime after);
    List<AnomalyEvent> findBySeverity(String severity);
}
package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.TrackerEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface TrackerEventRepository extends JpaRepository<TrackerEvent, Long> {
    Optional<TrackerEvent> findByClientEventId(String clientEventId);
}

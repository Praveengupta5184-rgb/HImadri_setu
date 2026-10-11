package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.TrackerSession;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;

public interface TrackerSessionRepository extends JpaRepository<TrackerSession, Long> {
    Optional<TrackerSession> findByTracker_DeviceIdAndStatusIn(String deviceId, List<String> statuses);
    Optional<TrackerSession> findByCargo_IdAndStatusIn(Long cargoId, List<String> statuses);
}

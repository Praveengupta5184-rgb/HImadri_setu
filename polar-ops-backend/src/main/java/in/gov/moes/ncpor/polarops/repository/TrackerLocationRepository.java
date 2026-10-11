package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.TrackerLocation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface TrackerLocationRepository extends JpaRepository<TrackerLocation, Long> {
    Optional<TrackerLocation> findByClientUuid(String clientUuid);
}

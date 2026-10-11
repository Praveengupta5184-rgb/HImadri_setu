package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.TrackerDevice;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface TrackerDeviceRepository extends JpaRepository<TrackerDevice, Long> {
    Optional<TrackerDevice> findByDeviceId(String deviceId);
}

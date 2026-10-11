package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CargoTrackingEventRepository extends JpaRepository<CargoTrackingEvent, Long> {
    List<CargoTrackingEvent> findByCargoIdOrderByTimestampDesc(Long cargoId);
}

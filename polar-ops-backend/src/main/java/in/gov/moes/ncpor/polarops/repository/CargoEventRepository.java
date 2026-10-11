package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.CargoEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CargoEventRepository extends JpaRepository<CargoEvent, Long> {
    List<CargoEvent> findByCargoPackageId(Long cargoPackageId);
}
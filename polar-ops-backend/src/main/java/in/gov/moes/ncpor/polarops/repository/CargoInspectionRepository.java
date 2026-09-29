package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.CargoInspection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CargoInspectionRepository extends JpaRepository<CargoInspection, Long> {
}

package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.CargoPackage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CargoRepository extends JpaRepository<CargoPackage, Long> {
    java.util.Optional<CargoPackage> findByCargoId(String cargoId);
    long countByCurrentStatus(String currentStatus);
}

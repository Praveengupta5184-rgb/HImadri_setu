package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.Personnel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PersonnelRepository extends JpaRepository<Personnel, Long> {
    List<Personnel> findByCurrentLocation(String currentLocation);
    long countByMovementStatus(String movementStatus);
}

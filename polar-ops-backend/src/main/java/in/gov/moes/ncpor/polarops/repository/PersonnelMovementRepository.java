package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.PersonnelMovement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PersonnelMovementRepository extends JpaRepository<PersonnelMovement, Long> {
}

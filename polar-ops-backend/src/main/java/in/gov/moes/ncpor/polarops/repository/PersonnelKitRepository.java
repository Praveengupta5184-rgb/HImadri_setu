package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.PersonnelKit;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PersonnelKitRepository extends JpaRepository<PersonnelKit, Long> {
    List<PersonnelKit> findByPersonnelId(Long personnelId);
}

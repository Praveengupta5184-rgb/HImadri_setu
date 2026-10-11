package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.PersonnelMovementHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PersonnelMovementHistoryRepository extends JpaRepository<PersonnelMovementHistory, Long> {
    List<PersonnelMovementHistory> findByPersonnelId(Long personnelId);
    List<PersonnelMovementHistory> findByPersonnelIdOrderByMovementTimeDesc(Long personnelId);
}
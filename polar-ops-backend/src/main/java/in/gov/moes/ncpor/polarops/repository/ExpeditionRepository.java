package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.Expedition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ExpeditionRepository extends JpaRepository<Expedition, Long> {
    long countByStatus(String status);
}

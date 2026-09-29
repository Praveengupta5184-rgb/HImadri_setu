package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.Station;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface StationRepository extends JpaRepository<Station, Long> {
}

package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.EmergencyIncident;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface EmergencyIncidentRepository extends JpaRepository<EmergencyIncident, Long> {
    long countByStatus(String status);
    List<EmergencyIncident> findByLocation(String location);
    List<EmergencyIncident> findByMissionId(Long missionId);
}

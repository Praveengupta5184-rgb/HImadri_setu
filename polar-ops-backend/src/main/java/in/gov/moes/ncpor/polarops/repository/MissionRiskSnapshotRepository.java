package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.MissionRiskSnapshot;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface MissionRiskSnapshotRepository extends JpaRepository<MissionRiskSnapshot, Long> {
    List<MissionRiskSnapshot> findByMissionIdOrderBySnapshotTimeDesc(Long missionId);
    MissionRiskSnapshot findFirstByMissionIdOrderBySnapshotTimeDesc(Long missionId);
}
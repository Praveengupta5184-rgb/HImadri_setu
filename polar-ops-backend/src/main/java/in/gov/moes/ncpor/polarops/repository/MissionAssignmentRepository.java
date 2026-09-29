package in.gov.moes.ncpor.polarops.repository; import in.gov.moes.ncpor.polarops.model.MissionAssignment; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface MissionAssignmentRepository extends JpaRepository<MissionAssignment,Long>{ List<MissionAssignment> findByMissionId(Long missionId); }

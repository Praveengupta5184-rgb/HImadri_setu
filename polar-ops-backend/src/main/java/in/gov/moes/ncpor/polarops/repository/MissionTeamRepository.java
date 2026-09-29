package in.gov.moes.ncpor.polarops.repository; import in.gov.moes.ncpor.polarops.model.MissionTeam; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface MissionTeamRepository extends JpaRepository<MissionTeam,Long>{ 
    List<MissionTeam> findByMissionId(Long missionId);
    long countByMissionId(Long missionId);
}

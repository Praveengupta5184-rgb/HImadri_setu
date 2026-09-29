package in.gov.moes.ncpor.polarops.repository; import in.gov.moes.ncpor.polarops.model.TeamTarget; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface TeamTargetRepository extends JpaRepository<TeamTarget,Long>{ List<TeamTarget> findByMissionId(Long missionId); }

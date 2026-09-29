package in.gov.moes.ncpor.polarops.repository; import in.gov.moes.ncpor.polarops.model.Mission; import org.springframework.data.jpa.repository.JpaRepository; import java.util.*;
public interface MissionRepository extends JpaRepository<Mission,Long>{ Optional<Mission> findByMissionCode(String missionCode); boolean existsByMissionCode(String missionCode); }

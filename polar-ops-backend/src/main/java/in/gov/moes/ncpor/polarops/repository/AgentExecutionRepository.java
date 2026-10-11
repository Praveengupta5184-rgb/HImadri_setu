package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.AgentExecution;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AgentExecutionRepository extends JpaRepository<AgentExecution, Long> {
    List<AgentExecution> findByMissionIdOrderByStartedAtDesc(Long missionId);
    AgentExecution findFirstByMissionIdOrderByStartedAtDesc(Long missionId);
}
package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.AgentApproval;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AgentApprovalRepository extends JpaRepository<AgentApproval, Long> {
    List<AgentApproval> findByRecommendationId(Long recommendationId);
    AgentApproval findFirstByRecommendationIdOrderByApprovedAtDesc(Long recommendationId);
}
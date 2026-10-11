package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AIRecommendationRepository extends JpaRepository<AIRecommendation, Long> {
    List<AIRecommendation> findByMissionIdOrderByGeneratedAtDesc(Long missionId);
    List<AIRecommendation> findByStatusOrderByGeneratedAtDesc(String status);
    List<AIRecommendation> findByModuleTypeAndStatusOrderByGeneratedAtDesc(String moduleType, String status);
    List<AIRecommendation> findByMissionIdAndStatusOrderByGeneratedAtDesc(Long missionId, String status);
    long countByStatus(String status);
}
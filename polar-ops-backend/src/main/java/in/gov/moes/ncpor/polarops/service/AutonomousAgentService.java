package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.dto.AgentExecutionResponse;
import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import in.gov.moes.ncpor.polarops.model.AgentExecution;
import in.gov.moes.ncpor.polarops.model.AgentApproval;
import in.gov.moes.ncpor.polarops.model.Mission;
import in.gov.moes.ncpor.polarops.repository.AIRecommendationRepository;
import in.gov.moes.ncpor.polarops.repository.AgentApprovalRepository;
import in.gov.moes.ncpor.polarops.repository.AgentExecutionRepository;
import in.gov.moes.ncpor.polarops.repository.MissionRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AutonomousAgentService {

    private final AgentExecutionRepository agentExecutionRepository;
    private final AIRecommendationRepository aiRecommendationRepository;
    private final AgentApprovalRepository agentApprovalRepository;
    private final MissionRepository missionRepository;
    private final MissionRiskService missionRiskService;

    public AgentExecutionResponse runAgent(Long missionId) {
        Mission mission = missionRepository.findById(missionId)
                .orElseThrow(() -> new IllegalArgumentException("Mission not found: " + missionId));

        AgentExecution execution = AgentExecution.builder()
                .missionId(missionId)
                .executionPhase("OBSERVING")
                .startedAt(LocalDateTime.now())
                .status("IN_PROGRESS")
                .aiMode("RULE_BASED_FALLBACK")
                .build();
        execution = agentExecutionRepository.save(execution);

        // OBSERVE & ANALYZE
        double riskScore = 0.0;
        try {
            riskScore = missionRiskService.assessMissionRisk(missionId).getMissionRiskScore();
            execution.setObservations("Risk score is " + riskScore);
            execution.setAnalysis("Analyzed mission risk parameters.");
        } catch(Exception e) {
            execution.setObservations("Failed to fetch risk score.");
            execution.setAnalysis("Error analyzing mission.");
        }

        // PREDICT
        execution.setExecutionPhase("PREDICTING");
        execution.setPredictions(riskScore > 0.6 ? "High risk of failure" : "Nominal operation expected");

        // EXPLAIN & RECOMMEND
        execution.setExecutionPhase("RECOMMENDING");
        execution.setExplanations("Based on risk factors, intervention might be necessary.");
        
        AIRecommendation recommendation = null;
        if (riskScore > 0.5) {
            recommendation = AIRecommendation.builder()
                    .missionId(missionId)
                    .recommendationType("RISK_MITIGATION")
                    .title("Halt Cargo Movement")
                    .explanation("High risk factors detected, cargo might be severely delayed or lost.")
                    .priority("HIGH")
                    .confidence(0.85)
                    .supportingFactors("Weather, Cargo Delays")
                    .generatedAt(LocalDateTime.now())
                    .status("PENDING")
                    .modelName("Agent-RuleEngine")
                    .modelVersion("1.0")
                    .build();
            aiRecommendationRepository.save(recommendation);
            execution.setRecommendations("Generated recommendation ID: " + recommendation.getId());
        } else {
            execution.setRecommendations("No recommendations needed.");
        }

        execution.setExecutionPhase("COMPLETED");
        execution.setStatus("COMPLETED");
        execution.setCompletedAt(LocalDateTime.now());
        agentExecutionRepository.save(execution);

        return AgentExecutionResponse.builder()
                .executionId(execution.getId())
                .status("SUCCESS")
                .message(recommendation != null ? "Recommendation generated" : "No recommendations needed")
                .build();
    }

    public List<AIRecommendation> getRecommendations() {
        return aiRecommendationRepository.findAll();
    }

    public AIRecommendation getRecommendation(Long id) {
        return aiRecommendationRepository.findById(id).orElseThrow();
    }

    public AIRecommendation approveRecommendation(Long id, Long approverId) {
        AIRecommendation rec = getRecommendation(id);
        rec.setStatus("APPROVED");
        aiRecommendationRepository.save(rec);

        AgentApproval approval = AgentApproval.builder()
                .recommendationId(id)
                .approvedBy(String.valueOf(approverId))
                .decision("APPROVE")
                .approvedAt(LocalDateTime.now())
                .comment("Approved by user")
                .build();
        agentApprovalRepository.save(approval);
        return rec;
    }

    public AIRecommendation rejectRecommendation(Long id, Long approverId) {
        AIRecommendation rec = getRecommendation(id);
        rec.setStatus("REJECTED");
        aiRecommendationRepository.save(rec);

        AgentApproval approval = AgentApproval.builder()
                .recommendationId(id)
                .approvedBy(String.valueOf(approverId))
                .decision("REJECT")
                .approvedAt(LocalDateTime.now())
                .comment("Rejected by user")
                .build();
        agentApprovalRepository.save(approval);
        return rec;
    }

    public AIRecommendation expireRecommendation(Long id) {
        AIRecommendation rec = getRecommendation(id);
        rec.setStatus("EXPIRED");
        aiRecommendationRepository.save(rec);
        return rec;
    }
}

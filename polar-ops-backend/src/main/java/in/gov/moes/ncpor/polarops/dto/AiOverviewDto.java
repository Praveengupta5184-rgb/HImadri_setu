package in.gov.moes.ncpor.polarops.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
@Builder
@lombok.NoArgsConstructor
@lombok.AllArgsConstructor
public class AiOverviewDto {
    private Double missionRiskScore;
    private String missionRiskLevel; // LOW, MEDIUM, HIGH, CRITICAL
    private int pendingRecommendations;
    private String agentStatus; // MONITORING, ANALYZING, IDLE
    
    // Summaries per module
    private Map<String, Integer> cargoRiskSummary; 
    private Map<String, Integer> inventoryRiskSummary;
    private Map<String, Integer> personnelRiskSummary;
    private Map<String, Integer> assetRiskSummary;
    private Map<String, String> weatherRiskSummary;
    private Map<String, Integer> emergencySummary;
    
    // Top active recommendations
    private List<AiRecommendationDto> topRecommendations;
}

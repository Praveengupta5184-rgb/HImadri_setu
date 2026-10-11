package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class MissionRiskResponse {
    private String missionId;
    private Integer missionRiskScore;
    private String riskLevel;
    private List<FactorContribution> factors;
    private Double confidence;
    private String aiMode;
    private String modelVersion;
    private String assessedAt;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class FactorContribution {
        private String name;
        private Double contribution;
        private String explanation;
    }
}
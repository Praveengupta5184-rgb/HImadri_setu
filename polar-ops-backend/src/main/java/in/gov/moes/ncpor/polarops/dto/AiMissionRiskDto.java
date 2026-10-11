package in.gov.moes.ncpor.polarops.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class AiMissionRiskDto {
    private double overallScore;
    private String riskLevel;
    private List<RiskFactorDto> factors;
    private String explanation;
    
    @Data
    @Builder
    public static class RiskFactorDto {
        private String factorName;
        private String riskLevel;
        private double contribution;
        private String description;
    }
}

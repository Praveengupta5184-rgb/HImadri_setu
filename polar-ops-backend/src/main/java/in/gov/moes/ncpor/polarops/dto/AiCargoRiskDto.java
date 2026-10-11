package in.gov.moes.ncpor.polarops.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class AiCargoRiskDto {
    private String cargoId;
    private String name;
    private String origin;
    private String destination;
    private String currentStatus;
    private String currentLocation;
    private String priority;
    private double riskScore;
    private String riskLevel;
    private List<String> riskFactors;
    private String recommendation;
}

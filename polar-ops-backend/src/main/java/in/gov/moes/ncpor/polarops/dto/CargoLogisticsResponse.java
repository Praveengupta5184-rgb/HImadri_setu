package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
import java.util.List;
import java.util.Map;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class CargoLogisticsResponse {
    private String cargoId;
    private Double delayProbability;
    private Double predictedDelayHours;
    private Integer criticalityScore;
    private String riskLevel;
    private Double confidence;
    private Map<String, Double> factors;
    private List<String> recommendations;
    private String aiMode;
    private String modelVersion;
}
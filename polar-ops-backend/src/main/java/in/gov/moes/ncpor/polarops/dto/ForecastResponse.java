package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
import java.util.Map;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ForecastResponse {
    private Long itemId;
    private String itemName;
    private Integer currentStock;
    private Integer predictedConsumption30Days;
    private Boolean shortageAlert;
    private Double shortageProbability;
    private Double confidence;
    private String expectedShortageDate;
    private Integer confidenceIntervalLower;
    private Integer confidenceIntervalUpper;
    private Integer recommendedProcurement;
    private String urgency;
    private Map<String, Double> factors;
    private String aiMode;
    private String modelVersion;
}
package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ForecastResponse {
    private Long itemId;
    private String itemName;
    private Integer currentStock;
    private Integer predictedConsumption30Days;
    private Boolean shortageAlert;
    private Integer confidenceIntervalLower;
    private Integer confidenceIntervalUpper;
    private Integer recommendedProcurement;
    private String urgency;
}

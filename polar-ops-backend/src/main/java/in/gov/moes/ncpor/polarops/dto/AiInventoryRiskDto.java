package in.gov.moes.ncpor.polarops.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class AiInventoryRiskDto {
    private String itemName;
    private String category;
    private int currentQuantity;
    private int predictedRequirement;
    private int expectedShortageDays;
    private double shortageProbability;
    private String riskLevel;
    private List<String> reasons;
    private String recommendation;
}

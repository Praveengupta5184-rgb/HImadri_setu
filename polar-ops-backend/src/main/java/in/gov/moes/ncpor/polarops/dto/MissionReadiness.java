package in.gov.moes.ncpor.polarops.dto;

import lombok.Builder;
import lombok.Data;
import java.util.List;

@Data
@Builder
public class MissionReadiness {
    private int overallScore; // 0-100
    private int cargoReadiness;
    private int inventoryReadiness;
    private int personnelReadiness;
    private int assetReadiness;
    private int emergencyReadiness;
    private int environmentalRisk;
    private List<String> reasons;
}

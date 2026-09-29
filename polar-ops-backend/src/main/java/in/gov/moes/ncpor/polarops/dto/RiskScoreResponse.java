package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
import java.util.List;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class RiskScoreResponse {
    private String cargoId;
    private int riskScore;
    private String riskLevel;
    private List<String> recommendations;
}

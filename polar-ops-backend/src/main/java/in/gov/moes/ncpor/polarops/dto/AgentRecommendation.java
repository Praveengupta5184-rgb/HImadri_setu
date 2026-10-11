package in.gov.moes.ncpor.polarops.dto;
import lombok.*;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AgentRecommendation {
    private Long recommendationId;
    private String type;
    private String title;
    private String explanation;
    private String priority;
    private Double confidence;
    private String supportingFactors;
    private String status;
    private String generatedAt;
}

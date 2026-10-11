package in.gov.moes.ncpor.polarops.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
@lombok.NoArgsConstructor
@lombok.AllArgsConstructor
public class AiRecommendationDto {
    private Long id;
    private Long missionId;
    private String moduleType;
    private String relatedEntityId;
    
    private String recommendationType;
    private String title;
    private String explanation;
    
    private String priority;
    private String severity;
    private Double confidence;
    private Double riskScore;
    
    private String supportingFactors;
    private String suggestedAction;
    
    private LocalDateTime generatedAt;
    private String status;
    private String approvedBy;
    private LocalDateTime approvedAt;
}

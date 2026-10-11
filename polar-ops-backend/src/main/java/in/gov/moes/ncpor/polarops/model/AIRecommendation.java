package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "ai_recommendations")
public class AIRecommendation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long missionId;
    
    @Column(name = "module_type")
    private String moduleType; // e.g., CARGO, INVENTORY, PERSONNEL, ASSET, WEATHER, EMERGENCY, MISSION
    
    @Column(name = "related_entity_id")
    private String relatedEntityId; // e.g., POLAR-CRG-021

    private String recommendationType;
    private String title;
    
    @Column(columnDefinition = "TEXT")
    private String explanation;
    
    private String priority;
    private String severity;
    private Double confidence;
    private Double riskScore; // 0 to 100
    
    @Column(columnDefinition = "TEXT")
    private String supportingFactors; // Can store JSON array of factors
    
    @Column(columnDefinition = "TEXT")
    private String suggestedAction;
    
    private LocalDateTime generatedAt;
    
    // Status: PENDING, APPROVED, REJECTED, EXECUTED, EXPIRED
    private String status;
    
    private String approvedBy;
    private LocalDateTime approvedAt;
    
    private String modelName;
    private String modelVersion;
}
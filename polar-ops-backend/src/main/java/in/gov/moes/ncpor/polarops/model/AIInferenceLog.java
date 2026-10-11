package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "ai_inference_logs")
public class AIInferenceLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String modelName;
    private String modelVersion;
    private String inputReference;
    private String prediction;
    private Double confidence;
    private LocalDateTime createdAt;
    private Long missionId;
    private Long cargoId;
    private Long inventoryItemId;
    private String aiMode;
}
package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "anomaly_events")
public class AnomalyEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String anomalyType;
    private String entityType;
    private Long entityId;
    private Double anomalyScore;
    private String severity;
    private String explanation;
    private LocalDateTime detectedAt;
    private String aiMode;
    private String modelName;
    private String modelVersion;
}
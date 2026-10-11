package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
import java.util.Map;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AnomalyDetectionResponse {
    private String entityType;
    private String entityId;
    private Double anomalyScore;
    private Boolean isAnomaly;
    private String anomalyType;
    private String severity;
    private String explanation;
    private String detectedAt;
    private String aiMode;
    private String modelVersion;
}
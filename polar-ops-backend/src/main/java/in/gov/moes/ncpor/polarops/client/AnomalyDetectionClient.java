package in.gov.moes.ncpor.polarops.client;

import in.gov.moes.ncpor.polarops.dto.AnomalyDetectionResponse;
import in.gov.moes.ncpor.polarops.model.AnomalyEvent;
import in.gov.moes.ncpor.polarops.repository.AnomalyEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AnomalyDetectionClient {

    private final RestTemplate restTemplate;
    private final AnomalyEventRepository anomalyEventRepository;

    @Value("${ai.anomaly.url}")
    private String aiAnomalyUrl;

    public AnomalyDetectionResponse detectAnomaly(String entityType, String entityId, Map<String, Double> features) {
        String url = aiAnomalyUrl + "/api/detect-anomaly";

        Map<String, Object> request = new HashMap<>();
        request.put("entity_type", entityType);
        request.put("entity_id", entityId);
        request.put("features", features);
        request.put("timestamp", LocalDateTime.now().toString());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        AnomalyDetectionResponse response;
        try {
            ResponseEntity<AnomalyDetectionResponse> apiResponse = restTemplate.postForEntity(url, entity, AnomalyDetectionResponse.class);
            if (apiResponse.getStatusCode() == HttpStatus.OK && apiResponse.getBody() != null) {
                response = apiResponse.getBody();
                log.info("AI anomaly detection successful for {}: {}", entityType, entityId);
            } else {
                response = deterministicFallback(entityType, entityId, features);
            }
        } catch (Exception e) {
            log.warn("AI anomaly detection service unavailable, using fallback: {}", e.getMessage());
            response = deterministicFallback(entityType, entityId, features);
        }

        // Store anomaly event if detected
        if (Boolean.TRUE.equals(response.getIsAnomaly())) {
            storeAnomalyEvent(response);
        }

        return response;
    }

    private void storeAnomalyEvent(AnomalyDetectionResponse response) {
        try {
            AnomalyEvent anomalyEvent = AnomalyEvent.builder()
                    .anomalyType(response.getAnomalyType())
                    .entityType(response.getEntityType())
                    .entityId(Long.parseLong(response.getEntityId()))
                    .anomalyScore(response.getAnomalyScore())
                    .severity(response.getSeverity())
                    .explanation(response.getExplanation())
                    .detectedAt(LocalDateTime.now())
                    .aiMode(response.getAiMode())
                    .modelName("IsolationForest")
                    .modelVersion(response.getModelVersion())
                    .build();
            anomalyEventRepository.save(anomalyEvent);
        } catch (Exception e) {
            log.error("Failed to store anomaly event: {}", e.getMessage());
        }
    }

    private AnomalyDetectionResponse deterministicFallback(String entityType, String entityId, Map<String, Double> features) {
        double anomalyScore = 0.0;
        String anomalyType = "NONE";
        String severity = "LOW";
        String explanation = "No anomalies detected";
        boolean isAnomaly = false;

        if ("cargo".equals(entityType)) {
            if (features.getOrDefault("delay_hours", 0.0) > 48) {
                anomalyScore = 0.8; anomalyType = "EXCESSIVE_DELAY"; severity = "HIGH";
                explanation = "Cargo delayed by " + features.get("delay_hours") + " hours"; isAnomaly = true;
            } else if (features.getOrDefault("days_to_deadline", 30.0) < 0) {
                anomalyScore = 0.9; anomalyType = "OVERDUE_DELIVERY"; severity = "CRITICAL";
                explanation = "Cargo delivery is overdue"; isAnomaly = true;
            }
        } else if ("inventory".equals(entityType)) {
            double stockRatio = features.getOrDefault("stock_level", 100.0) / Math.max(1, features.getOrDefault("min_stock", 50.0));
            if (stockRatio < 0.5) {
                anomalyScore = 0.85; anomalyType = "CRITICAL_STOCK_SHORTAGE"; severity = "CRITICAL";
                explanation = "Stock level at " + Math.round(stockRatio * 100) + "% of minimum"; isAnomaly = true;
            } else if (stockRatio < 1.0) {
                anomalyScore = 0.6; anomalyType = "LOW_STOCK"; severity = "HIGH";
                explanation = "Stock level below minimum threshold"; isAnomaly = true;
            }
        } else if ("personnel".equals(entityType)) {
            if (features.getOrDefault("time_since_update", 0.0) > 1800) {
                anomalyScore = 0.7; anomalyType = "STALE_LOCATION"; severity = "MODERATE";
                explanation = "Personnel location not updated recently"; isAnomaly = true;
            }
        } else if ("weather".equals(entityType)) {
            if (features.getOrDefault("storm_probability", 0.0) > 0.8) {
                anomalyScore = 0.75; anomalyType = "STORM_WARNING"; severity = "HIGH";
                explanation = "High probability of severe storm"; isAnomaly = true;
            }
        } else if ("asset".equals(entityType)) {
            if (features.getOrDefault("condition_score", 100.0) < 30) {
                anomalyScore = 0.7; anomalyType = "ASSET_DEGRADED"; severity = "HIGH";
                explanation = "Asset condition below operational threshold"; isAnomaly = true;
            }
        }

        return AnomalyDetectionResponse.builder()
                .entityType(entityType)
                .entityId(entityId)
                .anomalyScore(Math.round(anomalyScore * 1000.0) / 1000.0)
                .isAnomaly(isAnomaly)
                .anomalyType(isAnomaly ? anomalyType : "NONE")
                .severity(severity)
                .explanation(explanation)
                .detectedAt(LocalDateTime.now().toString())
                .aiMode("RULE_BASED_FALLBACK")
                .modelVersion("1.0.0-fallback")
                .build();
    }
}
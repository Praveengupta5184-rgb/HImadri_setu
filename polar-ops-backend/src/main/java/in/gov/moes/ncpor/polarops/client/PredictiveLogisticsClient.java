package in.gov.moes.ncpor.polarops.client;

import in.gov.moes.ncpor.polarops.dto.CargoLogisticsResponse;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class PredictiveLogisticsClient {

    private final RestTemplate restTemplate;

    @Value("${ai.logistics.url}")
    private String aiLogisticsUrl;

    public CargoLogisticsResponse predictCargoDelay(CargoPackage cargoPackage, Double weatherRiskScore, 
                                                     Double historicalDelayRate, Double packagingScore, 
                                                     Boolean inspectionPassed) {
        String url = aiLogisticsUrl + "/api/predict-delay";

        Map<String, Object> request = new HashMap<>();
        request.put("cargo_id", cargoPackage.getCargoId());
        request.put("deadline_days_remaining", getDaysUntilDeadline(cargoPackage));
        request.put("current_status", cargoPackage.getCurrentStatus());
        request.put("destination", cargoPackage.getDestination());
        request.put("is_hazardous", Boolean.TRUE.equals(cargoPackage.getHazardousStatus()));
        request.put("historical_delay_rate", historicalDelayRate != null ? historicalDelayRate : 0.0);
        request.put("transit_duration_hours", estimateTransitDuration(cargoPackage));
        request.put("weather_risk_score", weatherRiskScore != null ? weatherRiskScore : 0.0);
        request.put("packaging_condition_score", packagingScore != null ? packagingScore : 1.0);
        request.put("previous_inspection_passed", inspectionPassed != null ? inspectionPassed : true);
        request.put("logistics_provider", cargoPackage.getOwnerOrganization());

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        try {
            ResponseEntity<CargoLogisticsResponse> response = restTemplate.postForEntity(url, entity, CargoLogisticsResponse.class);
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                log.info("AI cargo logistics prediction successful for cargo: {}", cargoPackage.getCargoId());
                return response.getBody();
            }
        } catch (Exception e) {
            log.warn("AI predictive logistics service unavailable, using fallback: {}", e.getMessage());
        }

        return deterministicFallback(cargoPackage, weatherRiskScore, historicalDelayRate, packagingScore, inspectionPassed);
    }

    private int getDaysUntilDeadline(CargoPackage cargoPackage) {
        if (cargoPackage.getExpectedDeliveryDate() == null) return 30;
        return (int) java.time.temporal.ChronoUnit.DAYS.between(java.time.LocalDate.now(), cargoPackage.getExpectedDeliveryDate());
    }

    private double estimateTransitDuration(CargoPackage cargoPackage) {
        // Estimate based on destination - in real implementation this would be more sophisticated
        return 120.0; // 5 days default
    }

    private CargoLogisticsResponse deterministicFallback(CargoPackage cargoPackage, Double weatherRiskScore,
                                                          Double historicalDelayRate, Double packagingScore,
                                                          Boolean inspectionPassed) {
        int daysRemaining = getDaysUntilDeadline(cargoPackage);
        double delayProb = 0.1;

        if (daysRemaining < 0) delayProb += 0.4;
        else if (daysRemaining < 7) delayProb += 0.2;
        else if (daysRemaining < 14) delayProb += 0.1;

        if (Boolean.TRUE.equals(cargoPackage.getHazardousStatus())) delayProb += 0.15;
        delayProb += (historicalDelayRate != null ? historicalDelayRate : 0.0) * 0.3;
        delayProb += (weatherRiskScore != null ? weatherRiskScore : 0.0) * 0.15;
        delayProb += (1 - (packagingScore != null ? packagingScore : 1.0)) * 0.1;
        if (inspectionPassed != null && !inspectionPassed) delayProb += 0.1;
        if (cargoPackage.getCurrentStatus() != null && "DELAYED".equalsIgnoreCase(cargoPackage.getCurrentStatus().name())) delayProb += 0.3;
        else if (cargoPackage.getCurrentStatus() != null && "IN_TRANSIT".equalsIgnoreCase(cargoPackage.getCurrentStatus().name())) delayProb += 0.1;

        delayProb = Math.min(0.95, Math.max(0.05, delayProb));

        double baseDelay = Math.max(0, -daysRemaining) * 24;
        double predictedDelay = baseDelay + delayProb * 48;

        int criticality = (int) (delayProb * 50 + (Boolean.TRUE.equals(cargoPackage.getHazardousStatus()) ? 20 : 0) + 
                               (weatherRiskScore != null ? weatherRiskScore * 15 : 0) + 
                               (1 - (packagingScore != null ? packagingScore : 1.0)) * 15);
        criticality = Math.min(100, Math.max(0, criticality));

        String riskLevel = "LOW";
        if (criticality > 75) riskLevel = "CRITICAL";
        else if (criticality > 50) riskLevel = "HIGH";
        else if (criticality > 25) riskLevel = "MODERATE";

        Map<String, Double> factors = new HashMap<>();
        factors.put("deadlinePressure", daysRemaining < 7 ? Math.round(Math.max(0, (7 - daysRemaining) / 7.0 * 30) * 10.0) / 10.0 : 0);
        factors.put("hazardousMaterial", Boolean.TRUE.equals(cargoPackage.getHazardousStatus()) ? 15.0 : 0);
        factors.put("historicalDelays", Math.round((historicalDelayRate != null ? historicalDelayRate : 0.0) * 20 * 10.0) / 10.0);
        factors.put("weatherRisk", Math.round((weatherRiskScore != null ? weatherRiskScore : 0.0) * 15 * 10.0) / 10.0);
        factors.put("packagingQuality", Math.round((1 - (packagingScore != null ? packagingScore : 1.0)) * 10 * 10.0) / 10.0);
        factors.put("inspectionStatus", (inspectionPassed != null && !inspectionPassed) ? 10.0 : 0);

        java.util.List<String> recommendations = new java.util.ArrayList<>();
        if (daysRemaining < 10) recommendations.add("Expedite shipment - deadline approaching");
        if (Boolean.TRUE.equals(cargoPackage.getHazardousStatus())) recommendations.add("Verify hazardous material documentation");
        if ((packagingScore != null ? packagingScore : 1.0) < 0.7) recommendations.add("Reinforce packaging before transit");
        if ((weatherRiskScore != null ? weatherRiskScore : 0.0) > 0.6) recommendations.add("Monitor weather conditions closely");
        if (delayProb > 0.5) recommendations.add("Contact logistics provider for contingency planning");

        return CargoLogisticsResponse.builder()
                .cargoId(cargoPackage.getCargoId())
                .delayProbability(Math.round(delayProb * 100 * 10.0) / 10.0)
                .predictedDelayHours(Math.round(predictedDelay * 10.0) / 10.0)
                .criticalityScore(criticality)
                .riskLevel(riskLevel)
                .confidence(0.75)
                .factors(factors)
                .recommendations(recommendations)
                .aiMode("RULE_BASED_FALLBACK")
                .modelVersion("1.0.0-fallback")
                .build();
    }
}
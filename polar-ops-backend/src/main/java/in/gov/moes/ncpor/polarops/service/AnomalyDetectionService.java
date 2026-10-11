package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.client.AnomalyDetectionClient;
import in.gov.moes.ncpor.polarops.dto.AnomalyDetectionResponse;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.model.Asset;
import in.gov.moes.ncpor.polarops.model.WeatherObservation;
import in.gov.moes.ncpor.polarops.repository.CargoRepository;
import in.gov.moes.ncpor.polarops.repository.InventoryRepository;
import in.gov.moes.ncpor.polarops.repository.PersonnelRepository;
import in.gov.moes.ncpor.polarops.repository.AssetRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AnomalyDetectionService {

    private final AnomalyDetectionClient anomalyDetectionClient;
    private final CargoRepository cargoRepository;
    private final InventoryRepository inventoryRepository;
    private final PersonnelRepository personnelRepository;
    private final AssetRepository assetRepository;
    private final in.gov.moes.ncpor.polarops.repository.AnomalyEventRepository anomalyEventRepository;

    public AnomalyDetectionResponse checkCargoAnomalies(CargoPackage cargo) {
        Map<String, Double> features = new HashMap<>();
        features.put("delay_hours", calculateDelayHours(cargo));
        features.put("weight", cargo.getWeight() != null ? cargo.getWeight() : 0.0);
        features.put("hazardous", Boolean.TRUE.equals(cargo.getHazardousStatus()) ? 1.0 : 0.0);
        features.put("transit_duration", 120.0); // estimated
        features.put("weather_risk", 0.0); // would come from weather service
        features.put("packaging_score", 1.0); // from inspections
        features.put("inspection_score", 1.0);
        features.put("days_to_deadline", getDaysToDeadline(cargo));
        features.put("provider_reliability", 0.8);
        features.put("status_code", cargo.getCurrentStatus() != null && "DELAYED".equalsIgnoreCase(cargo.getCurrentStatus().name()) ? 1.0 : 0.0);

        return anomalyDetectionClient.detectAnomaly("cargo", cargo.getCargoId(), features);
    }

    public AnomalyDetectionResponse checkInventoryAnomalies(InventoryItem item) {
        Map<String, Double> features = new HashMap<>();
        features.put("consumption_rate", item.getDailyConsumptionRate() != null ? item.getDailyConsumptionRate() : 2.5);
        features.put("stock_level", item.getQuantityAvailable() != null ? item.getQuantityAvailable() : 0.0);
        features.put("min_stock", item.getMinimumStockLevel() != null ? item.getMinimumStockLevel() : 0.0);
        features.put("personnel_count", 25.0);
        features.put("season_factor", 1.0);
        features.put("days_since_restock", 30.0);
        features.put("expiry_proximity", item.getExpiryDate() != null ? 
            java.time.temporal.ChronoUnit.DAYS.between(LocalDateTime.now().toLocalDate(), item.getExpiryDate()) : 365.0);
        features.put("demand_trend", 1.0);
        features.put("supplier_lead_time", 14.0);
        features.put("criticality", 0.5);

        return anomalyDetectionClient.detectAnomaly("inventory", item.getItemId().toString(), features);
    }

    public AnomalyDetectionResponse checkPersonnelAnomalies(Personnel personnel) {
        Map<String, Double> features = new HashMap<>();
        features.put("location_accuracy", 10.0);
        features.put("movement_frequency", 1.0);
        features.put("battery_level", 80.0);
        features.put("signal_strength", -50.0);
        features.put("time_since_update", 300.0); // 5 minutes
        features.put("distance_from_base", 5000.0);
        features.put("activity_level", 0.5);
        features.put("health_score", 100.0);
        features.put("mission_duration", 30.0);
        features.put("team_size", 5.0);

        return anomalyDetectionClient.detectAnomaly("personnel", personnel.getId().toString(), features);
    }

    public AnomalyDetectionResponse checkAssetAnomalies(Asset asset) {
        Map<String, Double> features = new HashMap<>();
        features.put("operational_hours", 1000.0);
        features.put("maintenance_due", 0.0);
        features.put("failure_count", 0.0);
        features.put("condition_score", 80.0);
        features.put("usage_intensity", 0.5);
        features.put("age", 2.0);
        features.put("last_service_days", 30.0);
        features.put("criticality", 0.5);
        features.put("redundancy", 1.0);
        features.put("environment_score", 0.7);

        return anomalyDetectionClient.detectAnomaly("asset", asset.getId().toString(), features);
    }

    public AnomalyDetectionResponse checkWeatherAnomalies(WeatherObservation weather) {
        Map<String, Double> features = new HashMap<>();
        features.put("temperature", weather.getTemperature() != null ? weather.getTemperature() : -20.0);
        features.put("wind_speed", weather.getWindSpeed() != null ? weather.getWindSpeed() : 10.0);
        features.put("humidity", weather.getHumidity() != null ? weather.getHumidity() : 50.0);
        features.put("pressure", weather.getPressure() != null ? weather.getPressure() : 1013.0);
        features.put("visibility", 10.0);
        features.put("precipitation", 0.0);
        features.put("storm_probability", 0.0);
        features.put("temperature_trend", 0.0);
        features.put("wind_trend", 0.0);
        features.put("severity_index", 0.0);

        return anomalyDetectionClient.detectAnomaly("weather", weather.getStation(), features);
    }

    @Scheduled(fixedRate = 300000) // Every 5 minutes
    public void runPeriodicAnomalyDetection() {
        log.info("Running periodic anomaly detection...");
        
        // Check cargo anomalies
        cargoRepository.findAll().forEach(cargo -> handleResponse(checkCargoAnomalies(cargo), "cargo", cargo.getId()));
        
        // Check inventory anomalies
        inventoryRepository.findAll().forEach(item -> handleResponse(checkInventoryAnomalies(item), "inventory", item.getItemId()));
        
        // Check personnel anomalies
        personnelRepository.findAll().forEach(personnel -> handleResponse(checkPersonnelAnomalies(personnel), "personnel", personnel.getId()));
        
        // Check asset anomalies
        assetRepository.findAll().forEach(asset -> handleResponse(checkAssetAnomalies(asset), "asset", asset.getId()));
        
        log.info("Periodic anomaly detection completed");
    }

    private void handleResponse(AnomalyDetectionResponse response, String entityType, Long entityId) {
        if (response != null && Boolean.TRUE.equals(response.getIsAnomaly())) {
            in.gov.moes.ncpor.polarops.model.AnomalyEvent event = in.gov.moes.ncpor.polarops.model.AnomalyEvent.builder()
                .anomalyType(response.getAnomalyType())
                .entityType(entityType)
                .entityId(entityId)
                .anomalyScore(response.getAnomalyScore())
                .severity(response.getSeverity())
                .explanation(response.getExplanation())
                .detectedAt(LocalDateTime.now())
                .aiMode(response.getAiMode())
                .modelVersion(response.getModelVersion())
                .build();
            anomalyEventRepository.save(event);
        }
    }

    private double calculateDelayHours(CargoPackage cargo) {
        if (cargo.getExpectedDeliveryDate() == null) return 0;
        long daysDiff = java.time.temporal.ChronoUnit.DAYS.between(
            java.time.LocalDate.now(), cargo.getExpectedDeliveryDate());
        return daysDiff < 0 ? Math.abs(daysDiff) * 24 : 0;
    }

    private double getDaysToDeadline(CargoPackage cargo) {
        if (cargo.getExpectedDeliveryDate() == null) return 30;
        return java.time.temporal.ChronoUnit.DAYS.between(
            java.time.LocalDate.now(), cargo.getExpectedDeliveryDate());
    }
}
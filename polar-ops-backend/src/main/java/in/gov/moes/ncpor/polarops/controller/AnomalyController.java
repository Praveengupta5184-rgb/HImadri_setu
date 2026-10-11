package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.AnomalyDetectionResponse;
import in.gov.moes.ncpor.polarops.model.AnomalyEvent;
import in.gov.moes.ncpor.polarops.repository.AnomalyEventRepository;
import in.gov.moes.ncpor.polarops.service.AnomalyDetectionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/anomalies")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AnomalyController {

    private final AnomalyDetectionService anomalyDetectionService;
    private final AnomalyEventRepository anomalyEventRepository;

    @PostMapping("/detect/cargo/{cargoId}")
    public ResponseEntity<AnomalyDetectionResponse> detectCargoAnomaly(@PathVariable String cargoId) {
        // In real implementation, fetch cargo and call service
        return ResponseEntity.ok().build();
    }

    @PostMapping("/detect/inventory/{itemId}")
    public ResponseEntity<AnomalyDetectionResponse> detectInventoryAnomaly(@PathVariable Long itemId) {
        return ResponseEntity.ok().build();
    }

    @PostMapping("/detect/personnel/{personnelId}")
    public ResponseEntity<AnomalyDetectionResponse> detectPersonnelAnomaly(@PathVariable Long personnelId) {
        return ResponseEntity.ok().build();
    }

    @PostMapping("/detect/asset/{assetId}")
    public ResponseEntity<AnomalyDetectionResponse> detectAssetAnomaly(@PathVariable Long assetId) {
        return ResponseEntity.ok().build();
    }

    @GetMapping
    public ResponseEntity<List<AnomalyEvent>> getAllAnomalies() {
        return ResponseEntity.ok(anomalyEventRepository.findAll());
    }

    @GetMapping("/entity/{entityType}/{entityId}")
    public ResponseEntity<List<AnomalyEvent>> getAnomaliesByEntity(@PathVariable String entityType, @PathVariable Long entityId) {
        return ResponseEntity.ok(anomalyEventRepository.findByEntityTypeAndEntityId(entityType, entityId));
    }

    @GetMapping("/severity/{severity}")
    public ResponseEntity<List<AnomalyEvent>> getAnomaliesBySeverity(@PathVariable String severity) {
        return ResponseEntity.ok(anomalyEventRepository.findBySeverity(severity));
    }

    @PostMapping("/run")
    public ResponseEntity<Map<String, String>> runAnomalyDetection() {
        // Trigger manual run
        return ResponseEntity.ok(Map.of("status", "Anomaly detection triggered"));
    }
}
package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.service.TrackerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/trackers")
@RequiredArgsConstructor
public class TrackerController {
    private final TrackerService trackerService;

    @PostMapping("/register")
    public ResponseEntity<?> registerDevice(@RequestBody Map<String, Object> payload) {
        try {
            return ResponseEntity.ok(trackerService.registerDevice(payload));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/{deviceId}/attach-cargo")
    public ResponseEntity<?> attachCargo(@PathVariable String deviceId, @RequestBody Map<String, Long> payload) {
        try {
            Long cargoId = payload.get("cargoId");
            return ResponseEntity.ok(trackerService.attachCargo(deviceId, cargoId));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/{deviceId}/locations")
    public ResponseEntity<?> ingestLocations(@PathVariable String deviceId, @RequestBody List<Map<String, Object>> locations) {
        try {
            trackerService.ingestLocations(deviceId, locations);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @PostMapping("/{deviceId}/events")
    public ResponseEntity<?> ingestEvents(@PathVariable String deviceId, @RequestBody List<Map<String, Object>> events) {
        try {
            trackerService.ingestEvents(deviceId, events);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/active")
    public ResponseEntity<?> getActiveTrackers() {
        try {
            return ResponseEntity.ok(trackerService.getActiveTrackers());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}

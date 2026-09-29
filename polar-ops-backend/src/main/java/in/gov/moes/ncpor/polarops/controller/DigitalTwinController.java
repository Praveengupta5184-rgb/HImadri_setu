package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.model.StationArea;
import in.gov.moes.ncpor.polarops.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/twin")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DigitalTwinController {
    
    private final StationAreaRepository stationAreaRepository;
    private final PersonnelRepository personnelRepository;
    private final AssetRepository assetRepository;
    private final InventoryRepository inventoryRepository;
    private final EmergencyIncidentRepository emergencyRepository;

    @GetMapping("/areas")
    public ResponseEntity<?> getAreas(@RequestParam(required = false) String station) {
        if (station != null) {
            return ResponseEntity.ok(stationAreaRepository.findByStationName(station));
        }
        return ResponseEntity.ok(stationAreaRepository.findAll());
    }

    @GetMapping("/areas/{name}/details")
    public ResponseEntity<Map<String, Object>> getAreaDetails(@PathVariable String name) {
        Map<String, Object> details = new HashMap<>();
        
        details.put("personnel", personnelRepository.findByCurrentLocation(name));
        details.put("assets", assetRepository.findByLocation(name));
        details.put("inventory", inventoryRepository.findByLocation(name));
        
        // Filter out RESOLVED incidents for the active emergencies view
        details.put("incidents", emergencyRepository.findByLocation(name).stream()
                .filter(inc -> !"RESOLVED".equals(inc.getStatus()))
                .toList());

        return ResponseEntity.ok(details);
    }
}

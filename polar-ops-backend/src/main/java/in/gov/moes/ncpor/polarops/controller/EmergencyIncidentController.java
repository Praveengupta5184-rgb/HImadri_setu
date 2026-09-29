package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.model.EmergencyIncident;
import in.gov.moes.ncpor.polarops.service.EmergencyIncidentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/emergencies")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class EmergencyIncidentController {
    private final EmergencyIncidentService emergencyService;

    @GetMapping
    public ResponseEntity<List<EmergencyIncident>> getAll() {
        return ResponseEntity.ok(emergencyService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<EmergencyIncident> getById(@PathVariable Long id) {
        EmergencyIncident incident = emergencyService.getById(id);
        return incident != null ? ResponseEntity.ok(incident) : ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<EmergencyIncident> create(@RequestBody EmergencyIncident incident) {
        return ResponseEntity.ok(emergencyService.createIncident(incident));
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<EmergencyIncident> updateStatus(@PathVariable Long id, @RequestBody Map<String, String> payload) {
        String status = payload.get("status");
        String performedBy = payload.get("performedBy");
        String notes = payload.get("notes");
        
        EmergencyIncident updated = emergencyService.updateStatus(id, status, performedBy, notes);
        if (updated == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(updated);
    }
}

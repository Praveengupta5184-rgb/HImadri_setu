package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.model.SimulationResult;
import in.gov.moes.ncpor.polarops.service.SimulationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/simulate")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SimulationController {
    
    private final SimulationService simulationService;

    @PostMapping
    public ResponseEntity<SimulationResult> runSimulation(@RequestBody Map<String, Object> payload) {
        String scenario = (String) payload.getOrDefault("scenario", "UNKNOWN");
        return ResponseEntity.ok(simulationService.runScenario(scenario, payload));
    }
}

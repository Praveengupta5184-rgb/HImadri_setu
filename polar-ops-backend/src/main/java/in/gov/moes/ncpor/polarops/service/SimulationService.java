package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.SimulationResult;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.HashMap;

@Service
public class SimulationService {

    public SimulationResult runScenario(String scenarioType, Map<String, Object> params) {
        if ("CARGO_DELAY".equalsIgnoreCase(scenarioType)) {
            return simulateCargoDelay(params);
        }
        
        // Fallback generic scenario
        return simulateGeneric(scenarioType);
    }

    private SimulationResult simulateCargoDelay(Map<String, Object> params) {
        int delayHours = params.containsKey("delayHours") ? Integer.parseInt(params.get("delayHours").toString()) : 48;
        
        Map<String, Object> baseline = new HashMap<>();
        baseline.put("inventoryDepletion", "15 days");
        baseline.put("missionReadiness", "85%");
        
        Map<String, Object> simulated = new HashMap<>();
        simulated.put("inventoryDepletion", (15 - (delayHours/24)) + " days");
        simulated.put("missionReadiness", "70%");
        
        Map<String, Object> diffs = new HashMap<>();
        diffs.put("inventoryDepletion", "-" + (delayHours/24) + " days");
        diffs.put("missionReadiness", "-15%");
        
        return SimulationResult.builder()
            .scenarioType("CARGO_DELAY")
            .description("Cargo delayed by " + delayHours + " hours")
            .input("Delay = " + delayHours + " hrs")
            .assumptions("Linear consumption of critical supplies. No backup cargo flights available.")
            .calculationMethod("Rule-Based Heuristic (subtract delay duration from existing depletion buffer)")
            .baselineState(baseline)
            .simulatedState(simulated)
            .differences(diffs)
            .baselineRisk(25)
            .simulatedRisk(65)
            .riskChange(40)
            .affectedEntities(List.of("Food Supply Block A", "Medical Kit C", "Personnel: Scientific Team 3"))
            .possibleActions(List.of("Ration critical supplies", "Request emergency airlift from nearby base", "Halt non-essential generator operations"))
            .build();
    }
    
    private SimulationResult simulateGeneric(String scenario) {
        Map<String, Object> baseline = Map.of("Status", "Normal");
        Map<String, Object> simulated = Map.of("Status", "Compromised");
        Map<String, Object> diffs = Map.of("Status", "Negative Shift");
        
        return SimulationResult.builder()
            .scenarioType(scenario)
            .description("Generic operational impact simulation")
            .input("Scenario: " + scenario)
            .assumptions("Standard operational parameters")
            .calculationMethod("Heuristic baseline comparison")
            .baselineState(baseline)
            .simulatedState(simulated)
            .differences(diffs)
            .baselineRisk(10)
            .simulatedRisk(80)
            .riskChange(70)
            .affectedEntities(List.of("Station Infrastructure"))
            .possibleActions(List.of("Evacuate", "Dispatch Engineering Team"))
            .build();
    }
}

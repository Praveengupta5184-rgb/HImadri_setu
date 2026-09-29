package in.gov.moes.ncpor.polarops.model;

import lombok.Data;
import lombok.Builder;
import java.util.List;
import java.util.Map;

@Data
@Builder
public class SimulationResult {
    private String scenarioType;
    private String description;
    
    // Transparency
    private String input;
    private String assumptions;
    private String calculationMethod;
    
    // State Deltas
    private Map<String, Object> baselineState;
    private Map<String, Object> simulatedState;
    private Map<String, Object> differences;
    
    // Impacts
    private int baselineRisk;
    private int simulatedRisk;
    private int riskChange;
    
    private List<String> affectedEntities;
    private List<String> possibleActions;
}

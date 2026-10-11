package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.model.cargo.CargoStatus;
import in.gov.moes.ncpor.polarops.repository.AIRecommendationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CargoRiskService {
    
    private final CargoService cargoService;
    private final AIRecommendationRepository aiRecommendationRepository;

    public void analyzeCargoRisk(Long missionId) {
        List<CargoPackage> allCargo = cargoService.getAll();
        // Prototype heuristic: Look for DELAYED or DAMAGED cargo and create a recommendation
        
        for (CargoPackage cargo : allCargo) {
            // Check if there is already an active pending recommendation for this cargo
            boolean hasPending = !aiRecommendationRepository
                    .findByModuleTypeAndStatusOrderByGeneratedAtDesc("CARGO", "PENDING")
                    .stream()
                    .filter(rec -> cargo.getCargoId().equals(rec.getRelatedEntityId()))
                    .findAny()
                    .isEmpty();
                    
            if (hasPending) continue;
            
            if (cargo.getCurrentStatus() == CargoStatus.DELAYED || cargo.getCurrentStatus() == CargoStatus.DAMAGED) {
                // Generate a prototype recommendation
                double riskScore = 80.0;
                String explanation = "Cargo is currently marked as " + cargo.getCurrentStatus() + ". ";
                if (cargo.getCategory() != null && (cargo.getCategory().equalsIgnoreCase("MEDICAL") || cargo.getCategory().equalsIgnoreCase("FUEL"))) {
                    riskScore += 15.0;
                    explanation += "This is critical " + cargo.getCategory() + " inventory dependency. ";
                }
                
                AIRecommendation rec = AIRecommendation.builder()
                        .missionId(missionId)
                        .moduleType("CARGO")
                        .relatedEntityId(cargo.getCargoId())
                        .recommendationType("LOGISTICS_INTERVENTION")
                        .title("Critical Cargo Intervention Required")
                        .explanation(explanation)
                        .priority(riskScore > 85 ? "HIGH" : "MEDIUM")
                        .severity(cargo.getCurrentStatus() == CargoStatus.DAMAGED ? "CRITICAL" : "HIGH")
                        .confidence(0.92)
                        .riskScore(Math.min(100.0, riskScore))
                        .supportingFactors("[\"Existing Delay\", \"Inventory Dependency\"]")
                        .suggestedAction("Prioritize this cargo for the next safe transport window or allocate emergency reserve.")
                        .generatedAt(LocalDateTime.now())
                        .status("PENDING")
                        .modelName("DeterministicRiskPrototype")
                        .modelVersion("1.0")
                        .build();
                        
                aiRecommendationRepository.save(rec);
            }
        }
    }
}

package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.repository.AIRecommendationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class InventoryRiskService {
    
    private final InventoryService inventoryService;
    private final AIRecommendationRepository aiRecommendationRepository;

    public void analyzeInventoryRisk(Long missionId) {
        List<InventoryItem> allInventory = inventoryService.getAll();
        
        for (InventoryItem item : allInventory) {
            boolean hasPending = !aiRecommendationRepository
                    .findByModuleTypeAndStatusOrderByGeneratedAtDesc("INVENTORY", "PENDING")
                    .stream()
                    .filter(rec -> String.valueOf(item.getItemId()).equals(rec.getRelatedEntityId()))
                    .findAny()
                    .isEmpty();
                    
            if (hasPending) continue;
            
            // Heuristic: If current quantity is dangerously close to min threshold
            if (item.getQuantityAvailable() != null && item.getMinimumStockLevel() != null && item.getQuantityAvailable() <= (item.getMinimumStockLevel() * 1.2)) {
                double riskScore = 70.0;
                String explanation = "Inventory stock is approaching minimum thresholds. ";
                
                if (item.getQuantityAvailable() <= item.getMinimumStockLevel()) {
                    riskScore = 90.0;
                    explanation = "Inventory stock has breached the minimum safe threshold! ";
                }
                
                AIRecommendation rec = AIRecommendation.builder()
                        .missionId(missionId)
                        .moduleType("INVENTORY")
                        .relatedEntityId(String.valueOf(item.getItemId()))
                        .recommendationType("STOCK_REPLENISHMENT")
                        .title("Inventory Shortage Risk: " + item.getName())
                        .explanation(explanation + "Current: " + item.getQuantityAvailable() + ", Min: " + item.getMinimumStockLevel())
                        .priority(riskScore > 85 ? "HIGH" : "MEDIUM")
                        .severity(riskScore > 85 ? "CRITICAL" : "HIGH")
                        .confidence(0.85)
                        .riskScore(riskScore)
                        .supportingFactors("[\"Low Stock Level\", \"High Consumption Rate\"]")
                        .suggestedAction("Prioritize the next supply shipment and verify available emergency reserve stock immediately.")
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

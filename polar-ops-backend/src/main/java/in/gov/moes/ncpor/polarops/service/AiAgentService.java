package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.dto.AiOverviewDto;
import in.gov.moes.ncpor.polarops.dto.AiRecommendationDto;
import in.gov.moes.ncpor.polarops.dto.AiMapper;
import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import in.gov.moes.ncpor.polarops.repository.AIRecommendationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AiAgentService {
    
    private final RiskAnalysisService riskAnalysisService;
    private final AIRecommendationRepository recommendationRepository;
    private final AiMapper aiMapper;
    
    private final CargoRiskService cargoRiskService;
    private final InventoryRiskService inventoryRiskService;
    private final PersonnelRiskService personnelRiskService;
    private final EmergencyRiskService emergencyRiskService;
    private final CargoService cargoService;
    private final InventoryService inventoryService;

    public AiOverviewDto getAiOverview(Long missionId) {
        double score = riskAnalysisService.calculateOverallMissionRisk(missionId);
        String level = riskAnalysisService.getRiskLevel(score);
        
        long pendingCount = recommendationRepository.countByStatus("PENDING");
        
        List<AIRecommendation> activeRecs = recommendationRepository.findByStatusOrderByGeneratedAtDesc("PENDING");
        if (activeRecs.size() > 5) {
            activeRecs = activeRecs.subList(0, 5); // Top 5
        }
        
        Map<String, Integer> cargoRiskSummary = new HashMap<>();
        cargoRiskSummary.put("critical", 0);
        
        // Return structured data for the dashboard
        return AiOverviewDto.builder()
            .missionRiskScore(score)
            .missionRiskLevel(level)
            .pendingRecommendations((int) pendingCount)
            .agentStatus("MONITORING")
            .topRecommendations(aiMapper.toDtoList(activeRecs))
            .cargoRiskSummary(cargoRiskSummary)
            // Initialize others similarly as needed...
            .build();
    }

    public List<AiRecommendationDto> getRecommendations(Long missionId, String status) {
        List<AIRecommendation> recs;
        if (missionId != null && status != null) {
            recs = recommendationRepository.findByMissionIdAndStatusOrderByGeneratedAtDesc(missionId, status);
        } else if (status != null) {
            recs = recommendationRepository.findByStatusOrderByGeneratedAtDesc(status);
        } else if (missionId != null) {
            recs = recommendationRepository.findByMissionIdOrderByGeneratedAtDesc(missionId);
        } else {
            recs = recommendationRepository.findAll();
        }
        return aiMapper.toDtoList(recs);
    }
    
    public AiRecommendationDto approveRecommendation(Long id, String username) {
        return recommendationRepository.findById(id).map(rec -> {
            rec.setStatus("APPROVED");
            rec.setApprovedBy(username);
            rec.setApprovedAt(LocalDateTime.now());
            // TODO: Triggers the actual action via an EventBus or direct Service call based on Module Type
            return aiMapper.toDto(recommendationRepository.save(rec));
        }).orElse(null);
    }

    public AiRecommendationDto rejectRecommendation(Long id, String username) {
        return recommendationRepository.findById(id).map(rec -> {
            rec.setStatus("REJECTED");
            rec.setApprovedBy(username);
            rec.setApprovedAt(LocalDateTime.now());
            return aiMapper.toDto(recommendationRepository.save(rec));
        }).orElse(null);
    }
    
    public in.gov.moes.ncpor.polarops.dto.AiMissionRiskDto getMissionRisk(Long missionId) {
        double score = riskAnalysisService.calculateOverallMissionRisk(missionId);
        String level = riskAnalysisService.getRiskLevel(score);
        
        java.util.List<in.gov.moes.ncpor.polarops.dto.AiMissionRiskDto.RiskFactorDto> factors = new java.util.ArrayList<>();
        factors.add(in.gov.moes.ncpor.polarops.dto.AiMissionRiskDto.RiskFactorDto.builder()
            .factorName("Weather Risk")
            .riskLevel("LOW")
            .contribution(5.0)
            .description("Stable weather conditions.")
            .build());
            
        factors.add(in.gov.moes.ncpor.polarops.dto.AiMissionRiskDto.RiskFactorDto.builder()
            .factorName("Cargo Delay Risk")
            .riskLevel("MEDIUM")
            .contribution(8.0)
            .description("Some cargo delays predicted.")
            .build());
            
        factors.add(in.gov.moes.ncpor.polarops.dto.AiMissionRiskDto.RiskFactorDto.builder()
            .factorName("Inventory Risk")
            .riskLevel("LOW")
            .contribution(4.0)
            .description("Inventory stock levels are generally sufficient.")
            .build());

        return in.gov.moes.ncpor.polarops.dto.AiMissionRiskDto.builder()
            .overallScore(score)
            .riskLevel(level)
            .factors(factors)
            .explanation("Current mission risk is " + level + " based on aggregated operational conditions. Cargo delay contributes moderate operational risk.")
            .build();
    }

    public java.util.List<in.gov.moes.ncpor.polarops.dto.AiCargoRiskDto> getCargoRisks(Long missionId) {
        java.util.List<in.gov.moes.ncpor.polarops.dto.AiCargoRiskDto> result = new java.util.ArrayList<>();
        java.util.List<in.gov.moes.ncpor.polarops.model.CargoPackage> allCargo = cargoService.getAll();
        for (in.gov.moes.ncpor.polarops.model.CargoPackage cargo : allCargo) {
            if (cargo.getCurrentStatus() == in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.DELAYED || 
                cargo.getCurrentStatus() == in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.DAMAGED || 
                "CRITICAL".equalsIgnoreCase(cargo.getPriority())) {
                double riskScore = cargo.getCurrentStatus() == in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.DAMAGED ? 95.0 : 75.0;
                result.add(in.gov.moes.ncpor.polarops.dto.AiCargoRiskDto.builder()
                    .cargoId(cargo.getCargoId())
                    .name(cargo.getName())
                    .origin(cargo.getOrigin())
                    .destination(cargo.getDestination())
                    .currentStatus(cargo.getCurrentStatus() != null ? cargo.getCurrentStatus().name() : "UNKNOWN")
                    .currentLocation(cargo.getCurrentLocation())
                    .priority(cargo.getPriority())
                    .riskScore(riskScore)
                    .riskLevel(riskScore > 85 ? "HIGH" : "MEDIUM")
                    .riskFactors(java.util.Arrays.asList("Status: " + cargo.getCurrentStatus(), "Priority: " + cargo.getPriority()))
                    .recommendation("Review transport logistics and prioritize this shipment.")
                    .build());
            }
        }
        return result;
    }

    public java.util.List<in.gov.moes.ncpor.polarops.dto.AiInventoryRiskDto> getInventoryRisks(Long missionId) {
        java.util.List<in.gov.moes.ncpor.polarops.dto.AiInventoryRiskDto> result = new java.util.ArrayList<>();
        java.util.List<in.gov.moes.ncpor.polarops.model.InventoryItem> allInventory = inventoryService.getAll();
        for (in.gov.moes.ncpor.polarops.model.InventoryItem item : allInventory) {
            String derived = item.getDerivedStatus();
            if ("CRITICAL".equals(derived) || "OUT_OF_STOCK".equals(derived)) {
                int quantity = item.getQuantityAvailable() != null ? item.getQuantityAvailable() : 0;
                int req = item.getMinimumStockLevel() != null ? item.getMinimumStockLevel() * 2 : 10;
                result.add(in.gov.moes.ncpor.polarops.dto.AiInventoryRiskDto.builder()
                    .itemName(item.getName())
                    .category(item.getCategory())
                    .currentQuantity(quantity)
                    .predictedRequirement(req)
                    .expectedShortageDays(2)
                    .shortageProbability(0.9)
                    .riskLevel("HIGH")
                    .reasons(java.util.Arrays.asList("Current stock below minimum", "High consumption rate"))
                    .recommendation("Initiate emergency replenishment.")
                    .build());
            }
        }
        return result;
    }

    // Periodically run by a scheduled task, or manually triggered
    public void analyzeMission(Long missionId) {
        // Trigger risk engines to observe, detect, predict, and insert recommendations
        cargoRiskService.analyzeCargoRisk(missionId);
        inventoryRiskService.analyzeInventoryRisk(missionId);
        personnelRiskService.analyzePersonnelRisk(missionId);
        emergencyRiskService.analyzeEmergencyRisk(missionId);
    }
}

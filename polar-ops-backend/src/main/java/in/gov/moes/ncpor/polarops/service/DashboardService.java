package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.dto.DashboardData;
import in.gov.moes.ncpor.polarops.dto.MissionReadiness;
import in.gov.moes.ncpor.polarops.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final ExpeditionRepository expeditionRepository;
    private final CargoRepository cargoRepository;
    private final InventoryRepository inventoryRepository;
    private final PersonnelRepository personnelRepository;
    private final AssetRepository assetRepository;
    private final EmergencyIncidentRepository emergencyIncidentRepository;

    public DashboardData getDashboardData() {
        long activeExpeditions = expeditionRepository.countByStatus("ACTIVE");
        long cargoInTransit = cargoRepository.countByCurrentStatus("IN_TRANSIT");
        long inventoryCritical = inventoryRepository.findAll().stream()
                .filter(i -> "CRITICAL".equals(i.getDerivedStatus()) || "OUT_OF_STOCK".equals(i.getDerivedStatus()))
                .count();
        long personnelDeployed = personnelRepository.countByMovementStatus("FIELD_DEPLOYED");
        long criticalAssets = assetRepository.countByStatus("CRITICAL");
        long activeEmergencies = emergencyIncidentRepository.countByStatus("ACTIVE");

        MissionReadiness readiness = calculateReadiness();

        return DashboardData.builder()
                .activeExpeditions(activeExpeditions)
                .cargoInTransit(cargoInTransit)
                .inventoryCriticalItems(inventoryCritical)
                .personnelDeployed(personnelDeployed)
                .criticalAssets(criticalAssets)
                .activeEmergencies(activeEmergencies)
                .missionReadiness(readiness)
                .build();
    }

    private MissionReadiness calculateReadiness() {
        List<String> reasons = new ArrayList<>();
        
        // Derived readiness calculation based on live DB metrics
        
        long cargoIssues = cargoRepository.countByCurrentStatus("DELAYED") + cargoRepository.countByCurrentStatus("IN_TRANSIT");
        int cargoScore = cargoIssues == 0 ? 100 : Math.max(50, 100 - (int)(cargoIssues * 5));
        if (cargoScore < 90) reasons.add("Some cargo is currently delayed or in transit.");
        
        long criticalInv = inventoryRepository.findAll().stream()
                .filter(i -> "CRITICAL".equals(i.getDerivedStatus()) || "OUT_OF_STOCK".equals(i.getDerivedStatus()))
                .count();
        int inventoryScore = criticalInv == 0 ? 100 : Math.max(0, 100 - (int)(criticalInv * 10));
        if (inventoryScore < 90) reasons.add("Inventory levels need attention.");
        
        long deployedPersonnel = personnelRepository.countByMovementStatus("FIELD_DEPLOYED");
        int personnelScore = deployedPersonnel > 0 ? 95 : 100;
        
        long criticalAss = assetRepository.countByStatus("CRITICAL") + assetRepository.countByStatus("OFFLINE");
        int assetScore = criticalAss == 0 ? 100 : Math.max(20, 100 - (int)(criticalAss * 15));
        if (assetScore < 80) reasons.add("Critical assets require maintenance.");
        
        long activeEmergencies = emergencyIncidentRepository.count();
        int emergencyScore = activeEmergencies > 0 ? 50 : 100;
        if (emergencyScore < 80) reasons.add("Active emergency ongoing.");
        
        int envRisk = 15; // static low risk for now

        int overall = (cargoScore + inventoryScore + personnelScore + assetScore + emergencyScore) / 5;
        if (envRisk > 50) overall -= 10;

        return MissionReadiness.builder()
                .overallScore(overall)
                .cargoReadiness(cargoScore)
                .inventoryReadiness(inventoryScore)
                .personnelReadiness(personnelScore)
                .assetReadiness(assetScore)
                .emergencyReadiness(emergencyScore)
                .environmentalRisk(envRisk)
                .reasons(reasons)
                .build();
    }
}

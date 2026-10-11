package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.client.MissionRiskClient;
import in.gov.moes.ncpor.polarops.dto.MissionRiskResponse;
import in.gov.moes.ncpor.polarops.model.Mission;
import in.gov.moes.ncpor.polarops.repository.MissionRepository;
import in.gov.moes.ncpor.polarops.repository.MissionRiskSnapshotRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class MissionRiskService {

    private final MissionRiskClient missionRiskClient;
    private final MissionRepository missionRepository;
    private final MissionRiskSnapshotRepository missionRiskSnapshotRepository;
    private final in.gov.moes.ncpor.polarops.repository.CargoRepository cargoRepository;
    private final in.gov.moes.ncpor.polarops.repository.InventoryRepository inventoryRepository;
    private final in.gov.moes.ncpor.polarops.repository.MissionMemberRepository missionMemberRepository;
    private final in.gov.moes.ncpor.polarops.repository.EmergencyIncidentRepository emergencyIncidentRepository;
    private final in.gov.moes.ncpor.polarops.repository.AssetRepository assetRepository;

    public MissionRiskResponse assessMissionRisk(Long missionId) {
        Mission mission = missionRepository.findById(missionId).orElse(null);
        if (mission == null) {
            throw new IllegalArgumentException("Mission not found: " + missionId);
        }

        // In real implementation, these would be calculated from actual data
        // For now, use default values that will be enhanced
        Double weatherRisk = calculateWeatherRisk(mission);
        Double cargoDelayRisk = calculateCargoDelayRisk(mission);
        Double inventoryShortageRisk = calculateInventoryShortageRisk(mission);
        Double personnelShortageRisk = calculatePersonnelShortageRisk(mission);
        Integer activeEmergencies = calculateActiveEmergencies(mission);
        Double assetCondition = calculateAssetCondition(mission);
        Double locationRisk = calculateLocationRisk(mission);

        return missionRiskClient.assessMissionRisk(mission, weatherRisk, cargoDelayRisk,
                inventoryShortageRisk, personnelShortageRisk, activeEmergencies,
                assetCondition, locationRisk);
    }

    public List<MissionRiskResponse> assessAllMissions() {
        return missionRepository.findAll().stream()
                .map(mission -> assessMissionRisk(mission.getId()))
                .toList();
    }

    // Placeholder methods - in real implementation these would query actual data
    private Double calculateWeatherRisk(Mission mission) {
        // Find latest weather observation for mission's station
        // Fallback to random logic based on station name if no weather service available
        return 0.1; // Baseline
    }

    private Double calculateCargoDelayRisk(Mission mission) {
        // Query cargo service for mission cargo
        List<in.gov.moes.ncpor.polarops.model.CargoPackage> cargoes = cargoRepository.findAll().stream().filter(c -> c.getExpeditionId() != null && c.getExpeditionId().equals(mission.getExpedition().getId())).toList();
        if (cargoes.isEmpty()) return 0.0;
        
        long delayed = cargoes.stream().filter(c -> c.getCurrentStatus() != null && "DELAYED".equalsIgnoreCase(c.getCurrentStatus().name())).count();
        return Math.min(1.0, (double) delayed / cargoes.size());
    }

    private Double calculateInventoryShortageRisk(Mission mission) {
        // Query inventory service for mission inventory
        List<in.gov.moes.ncpor.polarops.model.InventoryItem> items = inventoryRepository.findAll();
        if (items.isEmpty()) return 0.0;
        
        long shortage = items.stream().filter(i -> i.getQuantityAvailable() != null && i.getMinimumStockLevel() != null && i.getQuantityAvailable() < i.getMinimumStockLevel()).count();
        return Math.min(1.0, (double) shortage / items.size());
    }

    private Double calculatePersonnelShortageRisk(Mission mission) {
        // Query personnel service for mission team
        long count = missionMemberRepository.countByMissionId(mission.getId());
        // assuming standard mission needs at least 5 people
        if (count < 5) return 0.5;
        return 0.1;
    }

    private Integer calculateActiveEmergencies(Mission mission) {
        // Query emergency service
        List<in.gov.moes.ncpor.polarops.model.EmergencyIncident> incidents = emergencyIncidentRepository.findByMissionId(mission.getId());
        return (int) incidents.stream().filter(i -> !"RESOLVED".equalsIgnoreCase(i.getStatus())).count();
    }

    private Double calculateAssetCondition(Mission mission) {
        // Query asset service
        List<in.gov.moes.ncpor.polarops.model.Asset> assets = assetRepository.findByMissionId(mission.getId());
        if (assets.isEmpty()) return 0.85;
        
        long faulty = assets.stream().filter(a -> "MAINTENANCE_REQUIRED".equalsIgnoreCase(a.getStatus()) || "OUT_OF_SERVICE".equalsIgnoreCase(a.getStatus())).count();
        return Math.max(0.0, 1.0 - ((double) faulty / assets.size()));
    }

    private Double calculateLocationRisk(Mission mission) {
        // Based on mission target zone
        if (mission.getTargetZone() != null && mission.getTargetZone().contains("Deep")) {
            return 0.8;
        }
        return 0.2;
    }
}
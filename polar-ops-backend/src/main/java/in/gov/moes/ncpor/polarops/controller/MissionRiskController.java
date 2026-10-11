package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.MissionRiskResponse;
import in.gov.moes.ncpor.polarops.model.MissionRiskSnapshot;
import in.gov.moes.ncpor.polarops.repository.MissionRiskSnapshotRepository;
import in.gov.moes.ncpor.polarops.service.MissionRiskService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/missions/risk")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MissionRiskController {

    private final MissionRiskService missionRiskService;
    private final MissionRiskSnapshotRepository missionRiskSnapshotRepository;

    @GetMapping("/{missionId}")
    public ResponseEntity<MissionRiskResponse> getMissionRisk(@PathVariable Long missionId) {
        MissionRiskResponse response = missionRiskService.assessMissionRisk(missionId);
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<MissionRiskResponse>> getAllMissionsRisk() {
        return ResponseEntity.ok(missionRiskService.assessAllMissions());
    }

    @GetMapping("/{missionId}/history")
    public ResponseEntity<List<MissionRiskSnapshot>> getMissionRiskHistory(@PathVariable Long missionId) {
        return ResponseEntity.ok(missionRiskSnapshotRepository.findByMissionIdOrderBySnapshotTimeDesc(missionId));
    }

    @GetMapping("/{missionId}/latest")
    public ResponseEntity<MissionRiskSnapshot> getLatestMissionRisk(@PathVariable Long missionId) {
        MissionRiskSnapshot snapshot = missionRiskSnapshotRepository.findFirstByMissionIdOrderBySnapshotTimeDesc(missionId);
        return snapshot != null ? ResponseEntity.ok(snapshot) : ResponseEntity.notFound().build();
    }
}
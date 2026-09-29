package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.LocationRequest;
import in.gov.moes.ncpor.polarops.model.*;
import in.gov.moes.ncpor.polarops.repository.*;
import in.gov.moes.ncpor.polarops.service.*;
import in.gov.moes.ncpor.polarops.service.ValidationService.ValidationResult;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.Year;
import java.util.*;

@RestController
@RequestMapping("/api/v1/missions")
@RequiredArgsConstructor
public class MissionController {

    private final MissionRepository missions;
    private final MissionTeamRepository teams;
    private final MissionMemberRepository members;
    private final TeamTargetRepository targets;
    private final MissionAssignmentRepository assignments;
    private final PersonnelLocationRepository locations;
    private final ExpeditionRepository expeditions;
    private final PersonnelRepository personnel;
    private final CargoRepository cargo;
    private final AssetRepository assets;
    private final EmergencyIncidentRepository emergencies;
    private final InventoryRepository inventory;
    private final MissionAccessService access;
    private final AuditService audit;
    private final LocationFreshnessService locationFreshness;
    private final ValidationService validationService;

    private Mission find(String code) {
        return missions.findByMissionCode(code)
                .orElseThrow(() -> new NoSuchElementException("Mission not found"));
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Mission m, Authentication a) {
        if (!access.isOfficer(a)) {
            return ResponseEntity.status(403).build();
        }
        if (m.getExpedition() == null || m.getExpedition().getId() == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "Expedition is required"));
        }
        m.setExpedition(expeditions.findById(m.getExpedition().getId()).orElseThrow());
        m.setMissionCode("POLAR-" + Year.now().getValue() + "-" + String.format("%03d", missions.count() + 1));
        if (m.getMissionName() == null || m.getMissionName().isBlank()) {
            m.setMissionName(m.getMissionCode());
        }
        m.setCreatedBy(a.getName());
        m.setCreatedAt(LocalDateTime.now());
        m.setUpdatedAt(LocalDateTime.now());
        if (m.getStatus() == null) {
            m.setStatus("PLANNED");
        }
        Mission saved = missions.save(m);
        audit.logAction(a.getName(), "MISSION_CREATED", saved.getMissionCode());
        return ResponseEntity.status(201).body(saved);
    }

    @GetMapping
    public ResponseEntity<?> list(Authentication a) {
        if (!access.isOfficer(a)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(missions.findAll());
    }

    @GetMapping("/{code}")
    public ResponseEntity<?> get(@PathVariable String code, Authentication a) {
        Mission m;
        try {
            m = find(code);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
        if (!access.canAccess(m, a)) {
            return ResponseEntity.status(403).build();
        }
        audit.logAction(a.getName(), "MISSION_ACCESSED", code);
        return ResponseEntity.ok(m);
    }

    @PostMapping("/{code}/teams")
    public ResponseEntity<?> team(@PathVariable String code, @RequestBody MissionTeam t, Authentication a) {
        Mission m = find(code);
        if (!access.isOfficer(a)) {
            return ResponseEntity.status(403).build();
        }
        t.setMission(m);
        t.setCreatedAt(LocalDateTime.now());
        t.setUpdatedAt(LocalDateTime.now());
        if (t.getStatus() == null) {
            t.setStatus("ACTIVE");
        }
        if (t.getTeamCode() == null || t.getTeamCode().isBlank()) {
            t.setTeamCode(m.getMissionCode() + "-TEAM-" + String.format("%02d", teams.countByMissionId(m.getId()) + 1));
        }
        if (t.getTeamName() == null || t.getTeamName().isBlank()) {
            t.setTeamName(t.getTeamCode());
        }
        return ResponseEntity.status(201).body(teams.save(t));
    }

    @GetMapping("/{code}/teams")
    public ResponseEntity<?> getTeams(@PathVariable String code, Authentication a) {
        Mission m = find(code);
        return access.canAccess(m, a)
                ? ResponseEntity.ok(teams.findByMissionId(m.getId()))
                : ResponseEntity.status(403).build();
    }

    @PostMapping("/{code}/teams/{teamId}/members/{personnelId}")
    public ResponseEntity<?> member(
            @PathVariable String code,
            @PathVariable Long teamId,
            @PathVariable Long personnelId,
            Authentication a) {
        Mission m = find(code);
        if (!access.isOfficer(a)) {
            return ResponseEntity.status(403).build();
        }

        ValidationResult personnelValidation = validationService.validatePersonnelExists(personnelId);
        if (!personnelValidation.valid()) {
            return ResponseEntity.status(404)
                    .body(Map.of("error", personnelValidation.errorCode(), "message", personnelValidation.message()));
        }

        if (members.existsByMissionIdAndPersonnelIdAndMembershipStatus(m.getId(), personnelId, "ACTIVE")) {
            return ResponseEntity.status(409).body(Map.of("message", "Personnel already has active membership"));
        }

        MissionTeam t = teams.findById(teamId)
                .filter(x -> x.getMission().getId().equals(m.getId()))
                .orElseThrow();
        Personnel p = personnel.findById(personnelId).orElseThrow();
        
        return ResponseEntity.status(201).body(members.save(
                MissionMember.builder()
                        .mission(m)
                        .team(t)
                        .personnel(p)
                        .roleInTeam(p.getRole())
                        .membershipStatus("ACTIVE")
                        .joinedAt(LocalDateTime.now())
                        .build()));
    }

    @GetMapping("/{code}/personnel")
    public ResponseEntity<?> personnel(@PathVariable String code, Authentication a) {
        Mission m = find(code);
        return access.canAccess(m, a)
                ? ResponseEntity.ok(members.findByMissionIdAndMembershipStatus(m.getId(), "ACTIVE"))
                : ResponseEntity.status(403).build();
    }

    @PostMapping("/{code}/personnel/{personnelId}/location")
    public ResponseEntity<?> location(
            @PathVariable String code,
            @PathVariable Long personnelId,
            @RequestBody LocationRequest r,
            Authentication a) {
        Mission m = find(code);
        if (!access.canSendLocation(personnelId, m, a)) {
            return ResponseEntity.status(403).build();
        }
        if (r.getLatitude() == null || r.getLongitude() == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "Latitude and longitude are required"));
        }

        ValidationResult personnelValidation = validationService.validatePersonnelExists(personnelId);
        if (!personnelValidation.valid()) {
            return ResponseEntity.status(404)
                    .body(Map.of("error", personnelValidation.errorCode(), "message", personnelValidation.message()));
        }

        Personnel p = personnel.findById(personnelId).orElseThrow();
        return ResponseEntity.status(201).body(locations.save(
                PersonnelLocation.builder()
                        .mission(m)
                        .personnel(p)
                        .latitude(r.getLatitude())
                        .longitude(r.getLongitude())
                        .accuracyMeters(r.getAccuracyMeters())
                        .recordedAt(r.getRecordedAt() == null ? LocalDateTime.now() : r.getRecordedAt())
                        .source(r.getSource() == null ? "DEVICE" : r.getSource())
                        .movementStatus(r.getMovementStatus())
                        .deviceId(r.getDeviceId())
                        .batteryPercent(r.getBatteryPercent())
                        .build()));
    }

    @GetMapping("/{code}/locations")
    public ResponseEntity<?> locations(@PathVariable String code, Authentication a) {
        Mission m = find(code);
        if (!access.canAccess(m, a)) {
            return ResponseEntity.status(403).build();
        }
        return ResponseEntity.ok(locations.findByMissionIdOrderByRecordedAtDesc(m.getId()).stream()
                .map(location -> locationFreshness.toResponse(location, closed(m)))
                .toList());
    }

    @PostMapping("/{code}/targets")
    public ResponseEntity<?> target(@PathVariable String code, @RequestBody TeamTarget x, Authentication a) {
        Mission m = find(code);
        if (!access.isOfficer(a) || closed(m)) {
            return ResponseEntity.status(403).build();
        }
        if (x.getTeam() == null || x.getTeam().getId() == null) {
            return ResponseEntity.badRequest().build();
        }
        MissionTeam t = teams.findById(x.getTeam().getId())
                .filter(q -> q.getMission().getId().equals(m.getId()))
                .orElseThrow();
        x.setMission(m);
        x.setTeam(t);
        x.setCreatedAt(LocalDateTime.now());
        x.setUpdatedAt(LocalDateTime.now());
        return ResponseEntity.status(201).body(targets.save(x));
    }

    @GetMapping("/{code}/targets")
    public ResponseEntity<?> targets(@PathVariable String code, Authentication a) {
        Mission m = find(code);
        return access.canAccess(m, a)
                ? ResponseEntity.ok(targets.findByMissionId(m.getId()))
                : ResponseEntity.status(403).build();
    }

    @PutMapping("/{code}/targets/{id}")
    public ResponseEntity<?> updateTarget(
            @PathVariable String code,
            @PathVariable Long id,
            @RequestBody TeamTarget x,
            Authentication a) {
        Mission m = find(code);
        if (!access.isOfficer(a) || closed(m)) {
            return ResponseEntity.status(403).build();
        }
        TeamTarget old = targets.findById(id)
                .filter(q -> q.getMission().getId().equals(m.getId()))
                .orElseThrow();
        old.setCompletedValue(x.getCompletedValue());
        old.setStatus(x.getStatus());
        old.setUpdatedAt(LocalDateTime.now());
        return ResponseEntity.ok(targets.save(old));
    }

    @PostMapping("/{code}/assignments")
    public ResponseEntity<?> assignment(@PathVariable String code, @RequestBody MissionAssignment x, Authentication a) {
        Mission m = find(code);
        if (!access.isOfficer(a) || closed(m)) {
            return ResponseEntity.status(403).build();
        }
        if (x.getPersonnel() == null || x.getPersonnel().getId() == null
                || x.getTeam() == null || x.getTeam().getId() == null) {
            return ResponseEntity.badRequest().build();
        }

        Long pid = x.getPersonnel().getId();
        ValidationResult personnelValidation = validationService.validatePersonnelExists(pid);
        if (!personnelValidation.valid()) {
            return ResponseEntity.status(404)
                    .body(Map.of("error", personnelValidation.errorCode(), "message", personnelValidation.message()));
        }

        MissionTeam t = teams.findById(x.getTeam().getId())
                .filter(q -> q.getMission().getId().equals(m.getId()))
                .orElseThrow();
        
        if (!members.existsByMissionIdAndPersonnelIdAndMembershipStatus(m.getId(), pid, "ACTIVE")) {
            return ResponseEntity.status(409).body(Map.of("message", "Personnel is not an active mission member"));
        }
        
        x.setMission(m);
        x.setTeam(t);
        x.setPersonnel(personnel.findById(pid).orElseThrow());
        x.setCreatedAt(LocalDateTime.now());
        x.setUpdatedAt(LocalDateTime.now());
        return ResponseEntity.status(201).body(assignments.save(x));
    }

    @GetMapping("/{code}/assignments")
    public ResponseEntity<?> assignments(@PathVariable String code, Authentication a) {
        Mission m = find(code);
        return access.canAccess(m, a)
                ? ResponseEntity.ok(assignments.findByMissionId(m.getId()))
                : ResponseEntity.status(403).build();
    }

    @PutMapping("/{code}/assignments/{id}")
    public ResponseEntity<?> updateAssignment(
            @PathVariable String code,
            @PathVariable Long id,
            @RequestBody MissionAssignment x,
            Authentication a) {
        Mission m = find(code);
        if (!access.isOfficer(a) || closed(m)) {
            return ResponseEntity.status(403).build();
        }
        MissionAssignment old = assignments.findById(id)
                .filter(q -> q.getMission().getId().equals(m.getId()))
                .orElseThrow();
        old.setCompletedValue(x.getCompletedValue());
        old.setStatus(x.getStatus());
        old.setUpdatedAt(LocalDateTime.now());
        return ResponseEntity.ok(assignments.save(old));
    }

    @DeleteMapping("/{code}/members/{personnelId}")
    public ResponseEntity<?> remove(@PathVariable String code, @PathVariable Long personnelId, Authentication a) {
        Mission m = find(code);
        if (!access.isOfficer(a) || closed(m)) {
            return ResponseEntity.status(403).build();
        }
        MissionMember mm = members.findByMissionIdAndPersonnelId(m.getId(), personnelId).orElseThrow();
        mm.setMembershipStatus("INACTIVE");
        mm.setRemovedAt(LocalDateTime.now());
        members.save(mm);
        audit.logAction(a.getName(), "MISSION_MEMBER_REMOVED", code);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{code}/close")
    public ResponseEntity<?> close(@PathVariable String code, Authentication a) {
        Mission m = find(code);
        if (!access.isOfficer(a)) {
            return ResponseEntity.status(403).build();
        }
        m.setStatus("CLOSED");
        m.setUpdatedAt(LocalDateTime.now());
        missions.save(m);
        audit.logAction(a.getName(), "MISSION_CLOSED", code);
        return ResponseEntity.ok(m);
    }

    @GetMapping("/{code}/dashboard")
    public ResponseEntity<?> dashboard(@PathVariable String code, Authentication a) {
        Mission m = find(code);
        if (!access.canAccess(m, a)) {
            return ResponseEntity.status(403).build();
        }
        var ts = targets.findByMissionId(m.getId());
        var as = assignments.findByMissionId(m.getId());
        var ms = members.findByMissionIdAndMembershipStatus(m.getId(), "ACTIVE");
        
        double targetProgress = ts.stream()
                .map(TeamTarget::getProgressPercent)
                .filter(Objects::nonNull)
                .mapToDouble(Double::doubleValue)
                .average()
                .orElse(0);
        
        double assignmentProgress = as.stream()
                .map(MissionAssignment::getProgressPercent)
                .filter(Objects::nonNull)
                .mapToDouble(Double::doubleValue)
                .average()
                .orElse(0);
        
        long critical = inventory.findAll().stream()
                .filter(i -> !"NORMAL".equals(i.getDerivedStatus()))
                .count();
        long activeEmergency = emergencies.findByMissionId(m.getId()).stream()
                .filter(e -> !"RESOLVED".equals(e.getStatus()))
                .count();
        
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("mission", m);
        result.put("teamCount", teams.findByMissionId(m.getId()).size());
        result.put("activePersonnel", ms.size());
        result.put("targetCount", ts.size());
        result.put("assignmentCount", as.size());
        result.put("targetProgress", targetProgress);
        result.put("assignmentProgress", assignmentProgress);
        result.put("missionProgress", (targetProgress + assignmentProgress) / 2);
        result.put("locationCount", locations.findByMissionIdOrderByRecordedAtDesc(m.getId()).size());
        result.put("cargoCount", cargo.findAll().stream()
                .filter(c -> m.getExpedition().getId().equals(c.getExpeditionId()))
                .count());
        result.put("assetCount", assets.findByMissionId(m.getId()).size());
        result.put("activeEmergencies", activeEmergency);
        result.put("inventoryAttentionItems", critical);
        result.put("readiness", Math.max(0, 100 - (critical * 10) - (activeEmergency * 25)));
        return ResponseEntity.ok(result);
    }

    private boolean closed(Mission m) {
        return "CLOSED".equals(m.getStatus()) || "COMPLETED".equals(m.getStatus());
    }

    private ResponseEntity<?> closedResponse() {
        return ResponseEntity.status(409).body(Map.of("message", "Mission is closed; operational mutations are not permitted."));
    }
}
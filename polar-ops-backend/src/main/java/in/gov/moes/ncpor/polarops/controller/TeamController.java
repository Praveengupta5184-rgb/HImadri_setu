package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.TeamMemberDto;
import in.gov.moes.ncpor.polarops.dto.TeamViewDto;
import in.gov.moes.ncpor.polarops.model.MissionMember;
import in.gov.moes.ncpor.polarops.model.MissionTeam;
import in.gov.moes.ncpor.polarops.model.PersonnelLocation;
import in.gov.moes.ncpor.polarops.repository.MissionMemberRepository;
import in.gov.moes.ncpor.polarops.repository.MissionTeamRepository;
import in.gov.moes.ncpor.polarops.repository.PersonnelLocationRepository;
import in.gov.moes.ncpor.polarops.service.AuditService;
import in.gov.moes.ncpor.polarops.service.MissionAccessService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/teams")
@RequiredArgsConstructor
public class TeamController {

    private final MissionTeamRepository teamRepo;
    private final MissionMemberRepository memberRepo;
    private final PersonnelLocationRepository locationRepo;
    private final MissionAccessService access;
    private final AuditService audit;

    @GetMapping("/{teamCode}/members")
    public ResponseEntity<?> getTeamMembers(@PathVariable String teamCode, Authentication auth) {

        // 1. Find team by code (404 if not found)
        Optional<MissionTeam> teamOpt = teamRepo.findByTeamCode(teamCode);
        if (teamOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("message", "Team not found."));
        }
        MissionTeam team = teamOpt.get();

        // 2. Authorize: user must be an officer OR an active member of this specific team
        if (!access.canAccessTeam(team, auth)) {
            audit.logAction(auth.getName(), "TEAM_MEMBER_DATA_DENIED", teamCode);
            return ResponseEntity.status(403).body(Map.of("message", "You are not authorized to view this team."));
        }

        // 3. Get active team members
        List<MissionMember> members = memberRepo.findByTeamId(team.getId())
                .stream()
                .filter(m -> "ACTIVE".equals(m.getMembershipStatus()))
                .collect(Collectors.toList());

        // 4. Build safe DTOs - fetch last known location per member
        Long missionId = team.getMission().getId();
        List<TeamMemberDto> memberDtos = members.stream().map(m -> {
            Optional<PersonnelLocation> locOpt = locationRepo
                    .findFirstByPersonnelIdAndMissionIdOrderByRecordedAtDesc(
                            m.getPersonnel().getId(), missionId);

            TeamMemberDto.LocationDto locationDto = null;
            if (locOpt.isPresent()) {
                PersonnelLocation loc = locOpt.get();
                locationDto = TeamMemberDto.LocationDto.builder()
                        .latitude(loc.getLatitude())
                        .longitude(loc.getLongitude())
                        .updatedAt(loc.getRecordedAt() != null ? loc.getRecordedAt().toString() : null)
                        .build();
            }

            return TeamMemberDto.builder()
                    .personnelId(m.getPersonnel().getId())
                    .name(m.getPersonnel().getName())
                    .role(m.getRoleInTeam() != null ? m.getRoleInTeam() : m.getPersonnel().getRole())
                    .assignmentStatus(m.getMembershipStatus())
                    .availability(m.getPersonnel().getMovementStatus())
                    .location(locationDto)
                    .build();
        }).collect(Collectors.toList());

        // 5. Build team view DTO
        String leadName = team.getTeamLeader() != null ? team.getTeamLeader().getName() : null;
        TeamViewDto view = TeamViewDto.builder()
                .teamCode(team.getTeamCode())
                .teamName(team.getTeamName())
                .missionCode(team.getMission().getMissionCode())
                .missionName(team.getMission().getMissionName())
                .teamLeadName(leadName)
                .status(team.getStatus())
                .memberCount(members.size())
                .members(memberDtos)
                .build();

        // 6. Audit successful access
        audit.logAction(auth.getName(), "TEAM_MEMBER_DATA_VIEWED", teamCode);

        return ResponseEntity.ok(view);
    }

    // Returns only teams the current user is an active member of (for hints/autocomplete)
    @GetMapping("/mine")
    public ResponseEntity<?> getMyTeams(Authentication auth) {
        List<Map<String, String>> result = memberRepo.findAll().stream()
                .filter(m -> "ACTIVE".equals(m.getMembershipStatus()))
                .filter(m -> access.canAccessTeam(m.getTeam(), auth))
                .map(m -> Map.of(
                        "teamCode", m.getTeam().getTeamCode(),
                        "teamName", m.getTeam().getTeamName() != null ? m.getTeam().getTeamName() : ""
                ))
                .distinct()
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }
}

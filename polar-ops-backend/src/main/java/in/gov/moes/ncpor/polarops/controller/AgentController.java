package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.AgentExecutionResponse;
import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import in.gov.moes.ncpor.polarops.service.AutonomousAgentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/agent")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AgentController {

    private final AutonomousAgentService agentService;

    @PostMapping("/run")
    @PreAuthorize("hasRole('MISSION_OFFICER') or hasRole('ADMIN')")
    public ResponseEntity<AgentExecutionResponse> runAgent(@RequestBody Map<String, Long> payload) {
        Long missionId = payload.get("missionId");
        if (missionId == null) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(agentService.runAgent(missionId));
    }

    @GetMapping("/recommendations")
    public ResponseEntity<List<AIRecommendation>> getRecommendations() {
        return ResponseEntity.ok(agentService.getRecommendations());
    }

    @GetMapping("/recommendations/{id}")
    public ResponseEntity<AIRecommendation> getRecommendation(@PathVariable Long id) {
        return ResponseEntity.ok(agentService.getRecommendation(id));
    }

    @PostMapping("/recommendations/{id}/approve")
    @PreAuthorize("hasRole('MISSION_OFFICER') or hasRole('ADMIN')")
    public ResponseEntity<AIRecommendation> approveRecommendation(@PathVariable Long id, @RequestHeader(value = "X-User-Id", defaultValue = "1") Long approverId) {
        // Real implementation would extract user from security context
        return ResponseEntity.ok(agentService.approveRecommendation(id, approverId));
    }

    @PostMapping("/recommendations/{id}/reject")
    @PreAuthorize("hasRole('MISSION_OFFICER') or hasRole('ADMIN')")
    public ResponseEntity<AIRecommendation> rejectRecommendation(@PathVariable Long id, @RequestHeader(value = "X-User-Id", defaultValue = "1") Long approverId) {
        return ResponseEntity.ok(agentService.rejectRecommendation(id, approverId));
    }

    @PostMapping("/recommendations/{id}/expire")
    @PreAuthorize("hasRole('MISSION_OFFICER') or hasRole('ADMIN')")
    public ResponseEntity<AIRecommendation> expireRecommendation(@PathVariable Long id) {
        return ResponseEntity.ok(agentService.expireRecommendation(id));
    }
}

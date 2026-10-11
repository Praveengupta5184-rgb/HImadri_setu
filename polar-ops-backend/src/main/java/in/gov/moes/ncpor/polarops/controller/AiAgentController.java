package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.AiOverviewDto;
import in.gov.moes.ncpor.polarops.dto.AiRecommendationDto;
import in.gov.moes.ncpor.polarops.service.AiAgentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/ai")
@RequiredArgsConstructor
@Tag(name = "AI Decision Intelligence", description = "AI-Assisted Mission Control and Risk Intelligence")
@CrossOrigin(origins = "*")
public class AiAgentController {
    
    private final AiAgentService aiAgentService;

    @GetMapping("/overview")
    @Operation(summary = "Get overall AI intelligence overview dashboard")
    public ResponseEntity<AiOverviewDto> getOverview(@RequestParam(required = false) Long missionId) {
        return ResponseEntity.ok(aiAgentService.getAiOverview(missionId));
    }

    @GetMapping("/recommendations")
    @Operation(summary = "Get AI recommendations")
    public ResponseEntity<List<AiRecommendationDto>> getRecommendations(
            @RequestParam(required = false) Long missionId,
            @RequestParam(required = false) String status) {
        return ResponseEntity.ok(aiAgentService.getRecommendations(missionId, status));
    }

    @PostMapping("/recommendations/{id}/approve")
    @Operation(summary = "Human-in-the-loop: Approve an AI recommendation")
    public ResponseEntity<AiRecommendationDto> approveRecommendation(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String token) {
        
        // TODO: Extract username from token
        String username = "MissionOfficer"; 
        
        AiRecommendationDto approved = aiAgentService.approveRecommendation(id, username);
        return approved != null ? ResponseEntity.ok(approved) : ResponseEntity.notFound().build();
    }

    @PostMapping("/recommendations/{id}/reject")
    @Operation(summary = "Human-in-the-loop: Reject an AI recommendation")
    public ResponseEntity<AiRecommendationDto> rejectRecommendation(
            @PathVariable Long id,
            @RequestHeader(value = "Authorization", required = false) String token) {
        
        // TODO: Extract username from token
        String username = "MissionOfficer"; 
        
        AiRecommendationDto rejected = aiAgentService.rejectRecommendation(id, username);
        return rejected != null ? ResponseEntity.ok(rejected) : ResponseEntity.notFound().build();
    }
    
    @GetMapping("/mission-risk")
    @Operation(summary = "Get detailed AI mission risk analysis")
    public ResponseEntity<in.gov.moes.ncpor.polarops.dto.AiMissionRiskDto> getMissionRisk(@RequestParam(required = false) Long missionId) {
        return ResponseEntity.ok(aiAgentService.getMissionRisk(missionId));
    }

    @GetMapping("/cargo-risks")
    @Operation(summary = "Get detailed AI cargo risk analysis")
    public ResponseEntity<List<in.gov.moes.ncpor.polarops.dto.AiCargoRiskDto>> getCargoRisks(@RequestParam(required = false) Long missionId) {
        return ResponseEntity.ok(aiAgentService.getCargoRisks(missionId));
    }

    @GetMapping("/inventory-risks")
    @Operation(summary = "Get detailed AI inventory risk analysis")
    public ResponseEntity<List<in.gov.moes.ncpor.polarops.dto.AiInventoryRiskDto>> getInventoryRisks(@RequestParam(required = false) Long missionId) {
        return ResponseEntity.ok(aiAgentService.getInventoryRisks(missionId));
    }
    
    @PostMapping("/analyze")
    @Operation(summary = "Force a synchronous AI risk analysis pass")
    public ResponseEntity<Void> analyzeMission(@RequestParam(required = false) Long missionId) {
        aiAgentService.analyzeMission(missionId);
        return ResponseEntity.ok().build();
    }
}

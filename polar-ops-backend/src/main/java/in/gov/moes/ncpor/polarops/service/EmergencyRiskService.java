package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import in.gov.moes.ncpor.polarops.model.EmergencyIncident;
import in.gov.moes.ncpor.polarops.repository.AIRecommendationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EmergencyRiskService {
    
    private final EmergencyIncidentService emergencyService;
    private final AIRecommendationRepository aiRecommendationRepository;

    public void analyzeEmergencyRisk(Long missionId) {
        List<EmergencyIncident> activeIncidents = emergencyService.getAll().stream()
            .filter(i -> !("RESOLVED".equals(i.getStatus()) || "CLOSED".equals(i.getStatus())))
            .collect(java.util.stream.Collectors.toList());
        
        for (EmergencyIncident incident : activeIncidents) {
            boolean hasPending = !aiRecommendationRepository
                    .findByModuleTypeAndStatusOrderByGeneratedAtDesc("EMERGENCY", "PENDING")
                    .stream()
                    .filter(rec -> String.valueOf(incident.getIncidentId()).equals(rec.getRelatedEntityId()))
                    .findAny()
                    .isEmpty();
                    
            if (hasPending) continue;
            
            if ("HIGH".equalsIgnoreCase(incident.getSeverity()) || "CRITICAL".equalsIgnoreCase(incident.getSeverity())) {
                double riskScore = "CRITICAL".equalsIgnoreCase(incident.getSeverity()) ? 100.0 : 85.0;
                
                AIRecommendation rec = AIRecommendation.builder()
                        .missionId(missionId)
                        .moduleType("EMERGENCY")
                        .relatedEntityId(String.valueOf(incident.getIncidentId()))
                        .recommendationType("EMERGENCY_RESPONSE")
                        .title("Active Emergency Escalation")
                        .explanation("Unresolved emergency incident detected: " + incident.getType() + " at " + incident.getLocation())
                        .priority("CRITICAL")
                        .severity(incident.getSeverity())
                        .confidence(0.99)
                        .riskScore(riskScore)
                        .supportingFactors("[\"Active Incident\", \"High Severity\"]")
                        .suggestedAction("Alert authorized nearby personnel and prepare medical response resources immediately.")
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

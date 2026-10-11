package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.AIRecommendation;
import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.repository.AIRecommendationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PersonnelRiskService {
    
    private final PersonnelService personnelService;
    private final AIRecommendationRepository aiRecommendationRepository;

    public void analyzePersonnelRisk(Long missionId) {
        List<Personnel> allPersonnel = personnelService.getAll();
        
        // Prototype heuristic: Detect if there's an unusually low number of medical personnel available
        List<Personnel> medicalStaff = allPersonnel.stream()
                .filter(p -> p.getRole() != null && p.getRole().toUpperCase().contains("MEDICAL"))
                .collect(Collectors.toList());
                
        // Count how many are available (not injured or in transit)
        long availableMedics = medicalStaff.stream()
                .filter(p -> p.getMovementStatus() != null && "AT_STATION".equalsIgnoreCase(p.getMovementStatus()))
                .count();
                
        if (availableMedics < 2) {
            boolean hasPending = !aiRecommendationRepository
                    .findByModuleTypeAndStatusOrderByGeneratedAtDesc("PERSONNEL", "PENDING")
                    .stream()
                    .filter(rec -> "MEDICAL_SHORTAGE".equals(rec.getRelatedEntityId()))
                    .findAny()
                    .isEmpty();
                    
            if (!hasPending) {
                double riskScore = availableMedics == 0 ? 95.0 : 65.0;
                
                AIRecommendation rec = AIRecommendation.builder()
                        .missionId(missionId)
                        .moduleType("PERSONNEL")
                        .relatedEntityId("MEDICAL_SHORTAGE")
                        .recommendationType("STAFFING_INTERVENTION")
                        .title("Medical Coverage Risk")
                        .explanation("System detected only " + availableMedics + " active medical officers available across all locations.")
                        .priority(availableMedics == 0 ? "CRITICAL" : "HIGH")
                        .severity(availableMedics == 0 ? "CRITICAL" : "MEDIUM")
                        .confidence(0.98)
                        .riskScore(riskScore)
                        .supportingFactors("[\"Low Medical Staff\", \"Operational Safety Requirement\"]")
                        .suggestedAction("Review personnel allocation and consider deploying additional medical officers.")
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

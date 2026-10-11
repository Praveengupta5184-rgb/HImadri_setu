package in.gov.moes.ncpor.polarops.client;

import in.gov.moes.ncpor.polarops.dto.MissionRiskResponse;
import in.gov.moes.ncpor.polarops.model.Mission;
import in.gov.moes.ncpor.polarops.model.MissionRiskSnapshot;
import in.gov.moes.ncpor.polarops.repository.MissionRiskSnapshotRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class MissionRiskClient {

    private final RestTemplate restTemplate;
    private final MissionRiskSnapshotRepository missionRiskSnapshotRepository;

    @Value("${ai.risk.url}")
    private String aiRiskUrl;

    public MissionRiskResponse assessMissionRisk(Mission mission, Double weatherRisk, Double cargoDelayRisk,
                                                  Double inventoryShortageRisk, Double personnelShortageRisk,
                                                  Integer activeEmergencies, Double assetCondition,
                                                  Double locationRisk) {
        String url = aiRiskUrl + "/api/assess-mission-risk";

        Map<String, Object> request = new HashMap<>();
        request.put("mission_id", mission.getMissionCode());
        request.put("weather_risk_score", weatherRisk != null ? weatherRisk : 0.0);
        request.put("cargo_delay_risk", cargoDelayRisk != null ? cargoDelayRisk : 0.0);
        request.put("inventory_shortage_risk", inventoryShortageRisk != null ? inventoryShortageRisk : 0.0);
        request.put("personnel_shortage_risk", personnelShortageRisk != null ? personnelShortageRisk : 0.0);
        request.put("active_emergencies", activeEmergencies != null ? activeEmergencies : 0);
        request.put("critical_asset_condition", assetCondition != null ? assetCondition : 1.0);
        request.put("location_risk_score", locationRisk != null ? locationRisk : 0.0);
        request.put("mission_duration_days", calculateMissionDuration(mission));
        request.put("team_size", getTeamSize(mission));

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        MissionRiskResponse response;
        try {
            ResponseEntity<MissionRiskResponse> apiResponse = restTemplate.postForEntity(url, entity, MissionRiskResponse.class);
            if (apiResponse.getStatusCode() == HttpStatus.OK && apiResponse.getBody() != null) {
                response = apiResponse.getBody();
                log.info("AI mission risk assessment successful for mission: {}", mission.getMissionCode());
            } else {
                response = deterministicFallback(mission, weatherRisk, cargoDelayRisk, inventoryShortageRisk,
                        personnelShortageRisk, activeEmergencies, assetCondition, locationRisk);
            }
        } catch (Exception e) {
            log.warn("AI mission risk service unavailable, using fallback: {}", e.getMessage());
            response = deterministicFallback(mission, weatherRisk, cargoDelayRisk, inventoryShortageRisk,
                    personnelShortageRisk, activeEmergencies, assetCondition, locationRisk);
        }

        // Store risk snapshot
        storeRiskSnapshot(mission, response);
        
        return response;
    }

    private void storeRiskSnapshot(Mission mission, MissionRiskResponse response) {
        try {
            String factorJson = new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(response.getFactors());
            
            MissionRiskSnapshot snapshot = MissionRiskSnapshot.builder()
                    .mission(mission)
                    .missionRiskScore(response.getMissionRiskScore())
                    .riskLevel(response.getRiskLevel())
                    .factorContributions(factorJson)
                    .snapshotTime(LocalDateTime.now())
                    .aiMode(response.getAiMode())
                    .build();
            missionRiskSnapshotRepository.save(snapshot);
        } catch (Exception e) {
            log.error("Failed to store mission risk snapshot: {}", e.getMessage());
        }
    }

    private int calculateMissionDuration(Mission mission) {
        if (mission.getStartDate() == null || mission.getEndDate() == null) return 30;
        return (int) java.time.temporal.ChronoUnit.DAYS.between(mission.getStartDate(), mission.getEndDate());
    }

    private int getTeamSize(Mission mission) {
        // In real implementation, query MissionMemberRepository
        return 10;
    }

    private MissionRiskResponse deterministicFallback(Mission mission, Double weatherRisk, Double cargoDelayRisk,
                                                       Double inventoryShortageRisk, Double personnelShortageRisk,
                                                       Integer activeEmergencies, Double assetCondition,
                                                       Double locationRisk) {
        double weather = weatherRisk != null ? weatherRisk : 0.0;
        double cargo = cargoDelayRisk != null ? cargoDelayRisk : 0.0;
        double inventory = inventoryShortageRisk != null ? inventoryShortageRisk : 0.0;
        double personnel = personnelShortageRisk != null ? personnelShortageRisk : 0.0;
        int emergencies = activeEmergencies != null ? activeEmergencies : 0;
        double asset = assetCondition != null ? assetCondition : 1.0;
        double location = locationRisk != null ? locationRisk : 0.0;

        List<MissionRiskResponse.FactorContribution> factors = new java.util.ArrayList<>();

        double weatherContrib = weather * 25;
        if (weatherContrib > 0) {
            factors.add(MissionRiskResponse.FactorContribution.builder()
                    .name("Weather")
                    .contribution(Math.round(weatherContrib * 10.0) / 10.0)
                    .explanation(String.format("Weather risk score: %.2f - %s", weather, 
                        weather > 0.7 ? "Severe conditions" : weather > 0.4 ? "Elevated risk" : "Monitor"))
                    .build());
        }

        double cargoContrib = cargo * 20;
        if (cargoContrib > 0) {
            factors.add(MissionRiskResponse.FactorContribution.builder()
                    .name("Cargo Delays")
                    .contribution(Math.round(cargoContrib * 10.0) / 10.0)
                    .explanation(String.format("Cargo delay probability: %.0f%% - %s", cargo * 100,
                        cargo > 0.7 ? "Critical delays expected" : cargo > 0.4 ? "Significant delays likely" : "Monitor shipments"))
                    .build());
        }

        double inventoryContrib = inventory * 20;
        if (inventoryContrib > 0) {
            factors.add(MissionRiskResponse.FactorContribution.builder()
                    .name("Inventory Shortage")
                    .contribution(Math.round(inventoryContrib * 10.0) / 10.0)
                    .explanation(String.format("Shortage probability: %.0f%% - %s", inventory * 100,
                        inventory > 0.7 ? "Critical stockouts projected" : inventory > 0.4 ? "Shortages likely" : "Monitor consumption"))
                    .build());
        }

        double personnelContrib = personnel * 15;
        if (personnelContrib > 0) {
            factors.add(MissionRiskResponse.FactorContribution.builder()
                    .name("Personnel Gaps")
                    .contribution(Math.round(personnelContrib * 10.0) / 10.0)
                    .explanation(String.format("Personnel risk: %.2f - %s", personnel,
                        personnel > 0.7 ? "Critical staffing shortage" : personnel > 0.4 ? "Staffing gaps identified" : "Adequate staffing"))
                    .build());
        }

        double emergencyContrib = Math.min(emergencies * 8, 25);
        if (emergencyContrib > 0) {
            factors.add(MissionRiskResponse.FactorContribution.builder()
                    .name("Active Emergencies")
                    .contribution(Math.round(emergencyContrib * 10.0) / 10.0)
                    .explanation(String.format("%d active emergency incident(s) - %s", emergencies,
                        emergencies > 2 ? "Multiple concurrent emergencies" : emergencies > 0 ? "Emergency response ongoing" : "No active emergencies"))
                    .build());
        }

        double assetContrib = (1 - asset) * 10;
        if (assetContrib > 0) {
            factors.add(MissionRiskResponse.FactorContribution.builder()
                    .name("Asset Condition")
                    .contribution(Math.round(assetContrib * 10.0) / 10.0)
                    .explanation(String.format("Critical asset health: %.0f%% - %s", asset * 100,
                        asset < 0.5 ? "Multiple assets degraded" : asset < 0.8 ? "Some assets need attention" : "Assets operational"))
                    .build());
        }

        double locationContrib = location * 10;
        if (locationContrib > 0) {
            factors.add(MissionRiskResponse.FactorContribution.builder()
                    .name("Location Risk")
                    .contribution(Math.round(locationContrib * 10.0) / 10.0)
                    .explanation(String.format("Mission location risk: %.2f - %s", location,
                        location > 0.7 ? "High risk environment" : location > 0.4 ? "Elevated environmental risk" : "Standard polar conditions"))
                    .build());
        }

        // Normalize contributions
        double total = factors.stream().mapToDouble(MissionRiskResponse.FactorContribution::getContribution).sum();
        if (total > 0) {
            for (MissionRiskResponse.FactorContribution f : factors) {
                f.setContribution(Math.round(f.getContribution() / total * 100 * 10.0) / 10.0);
            }
        }

        int missionRiskScore = (int) Math.round(factors.stream().mapToDouble(MissionRiskResponse.FactorContribution::getContribution).sum());
        missionRiskScore = Math.min(100, Math.max(0, missionRiskScore));

        String riskLevel = "LOW";
        if (missionRiskScore > 75) riskLevel = "CRITICAL";
        else if (missionRiskScore > 50) riskLevel = "HIGH";
        else if (missionRiskScore > 25) riskLevel = "MODERATE";

        return MissionRiskResponse.builder()
                .missionId(mission.getMissionCode())
                .missionRiskScore(missionRiskScore)
                .riskLevel(riskLevel)
                .factors(factors)
                .confidence(0.78)
                .aiMode("RULE_BASED_FALLBACK")
                .modelVersion("1.0.0-fallback")
                .assessedAt(LocalDateTime.now().toString())
                .build();
    }
}
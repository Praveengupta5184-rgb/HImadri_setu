package in.gov.moes.ncpor.polarops.client;

import in.gov.moes.ncpor.polarops.dto.ForecastResponse;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class InventoryForecastClient {

    private final RestTemplate restTemplate;

    @Value("${ai.inventory.url}")
    private String aiInventoryUrl;

    public ForecastResponse forecastInventory(InventoryItem item, int personnelCount, String season, String missionContext) {
        String url = aiInventoryUrl + "/api/forecast";

        // Get historical consumption from transactions
        List<Double> historicalConsumption = getHistoricalConsumption(item);

        Map<String, Object> request = new HashMap<>();
        request.put("item_id", item.getItemId().toString());
        request.put("historical_consumption", historicalConsumption);
        request.put("personnel_count", personnelCount);
        request.put("expedition_duration_days", 90);
        request.put("season", season);
        request.put("current_stock", item.getQuantityAvailable());
        request.put("minimum_stock", item.getMinimumStockLevel());
        request.put("mission_context", missionContext);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(request, headers);

        try {
            ResponseEntity<ForecastResponse> response = restTemplate.postForEntity(url, entity, ForecastResponse.class);
            if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null) {
                log.info("AI inventory forecast successful for item: {}", item.getName());
                return response.getBody();
            }
        } catch (Exception e) {
            log.warn("AI inventory forecast service unavailable, using fallback: {}", e.getMessage());
        }

        return deterministicFallback(item, personnelCount, season);
    }

    private List<Double> getHistoricalConsumption(InventoryItem item) {
        // In a real implementation, this would query InventoryConsumptionHistoryRepository
        // For now, return empty list to trigger default behavior
        return List.of();
    }

    private ForecastResponse deterministicFallback(InventoryItem item, int personnelCount, String season) {
        double avgDailyConsumption = item.getDailyConsumptionRate() != null ? item.getDailyConsumptionRate() : 2.5;
        
        // Seasonal adjustment
        double seasonalFactor = switch (season) {
            case "WINTER" -> 1.25;
            case "SPRING" -> 1.05;
            case "SUMMER" -> 0.95;
            case "AUTUMN" -> 1.0;
            default -> 1.0;
        };
        avgDailyConsumption *= seasonalFactor;
        
        // Personnel scaling
        avgDailyConsumption *= (personnelCount / 25.0);
        
        int predicted30 = (int) (avgDailyConsumption * 30);
        double shortageProb = predicted30 > 0 ? Math.min(100, Math.max(0, (predicted30 - item.getQuantityAvailable()) / (double) predicted30 * 100)) : 0;
        
        String shortageDate = null;
        if (item.getQuantityAvailable() > 0 && avgDailyConsumption > 0) {
            int daysLeft = (int) (item.getQuantityAvailable() / avgDailyConsumption);
            shortageDate = java.time.LocalDate.now().plusDays(daysLeft).toString();
        }
        
        int recommended = Math.max(0, predicted30 - item.getQuantityAvailable() + item.getMinimumStockLevel());
        
        Map<String, Double> factors = new HashMap<>();
        if (item.getQuantityAvailable() < item.getMinimumStockLevel() * 1.5) {
            factors.put("lowCurrentStock", 30.0 * (1 - item.getQuantityAvailable() / Math.max(1.0, item.getMinimumStockLevel() * 1.5)));
        }
        if (personnelCount > 30) {
            factors.put("personnelDemand", Math.min(25.0, (personnelCount - 25) * 1.5));
        }
        if ("WINTER".equals(season)) {
            factors.put("seasonalDemand", 20.0);
        }
        
        String urgency = shortageProb > 70 ? "HIGH" : shortageProb > 40 ? "MEDIUM" : "LOW";

        return ForecastResponse.builder()
                .itemId(item.getItemId())
                .itemName(item.getName())
                .currentStock(item.getQuantityAvailable())
                .predictedConsumption30Days(predicted30)
                .shortageAlert(shortageProb > 50)
                .shortageProbability(Math.round(shortageProb * 10.0) / 10.0)
                .confidence(0.75)
                .expectedShortageDate(shortageDate)
                .confidenceIntervalLower((int) (predicted30 * 0.8))
                .confidenceIntervalUpper((int) (predicted30 * 1.2))
                .recommendedProcurement(recommended)
                .urgency(urgency)
                .factors(factors)
                .aiMode("RULE_BASED_FALLBACK")
                .modelVersion("1.0.0-fallback")
                .build();
    }
}
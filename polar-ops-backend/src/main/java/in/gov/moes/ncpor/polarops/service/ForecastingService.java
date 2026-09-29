package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.dto.ForecastResponse;
import org.springframework.stereotype.Service;
@Service
public class ForecastingService {
    public ForecastResponse forecastInventory(InventoryItem item) {
        double avgDailyConsumption = 2.5; 
        int forecastDays = 30;
        double predictedConsumption = avgDailyConsumption * forecastDays;
        boolean shortageAlert = item.getQuantityAvailable() < predictedConsumption;
        int recommendedProcurement = (int) (predictedConsumption - item.getQuantityAvailable() + item.getMinimumStockLevel());
        
        return ForecastResponse.builder()
            .itemId(item.getItemId())
            .itemName(item.getName())
            .currentStock(item.getQuantityAvailable())
            .predictedConsumption30Days((int) predictedConsumption)
            .shortageAlert(shortageAlert)
            .confidenceIntervalLower((int) (predictedConsumption * 0.8))
            .confidenceIntervalUpper((int) (predictedConsumption * 1.2))
            .recommendedProcurement(Math.max(0, recommendedProcurement))
            .urgency(shortageAlert ? "HIGH" : "NORMAL")
            .build();
    }
}

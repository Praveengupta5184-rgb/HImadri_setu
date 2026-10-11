package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.client.InventoryForecastClient;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.dto.ForecastResponse;
import in.gov.moes.ncpor.polarops.repository.InventoryConsumptionHistoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ForecastingService {

    private final InventoryForecastClient inventoryForecastClient;
    private final InventoryConsumptionHistoryRepository consumptionHistoryRepository;

    public ForecastResponse forecastInventory(InventoryItem item, int personnelCount, String season, String missionContext) {
        return inventoryForecastClient.forecastInventory(item, personnelCount, season, missionContext);
    }

    public ForecastResponse forecastInventory(InventoryItem item) {
        // Default fallback for backward compatibility
        return forecastInventory(item, 25, "SUMMER", null);
    }
}
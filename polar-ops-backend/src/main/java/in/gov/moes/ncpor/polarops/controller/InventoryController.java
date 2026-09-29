package in.gov.moes.ncpor.polarops.controller;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.dto.ForecastResponse;
import in.gov.moes.ncpor.polarops.service.InventoryService;
import in.gov.moes.ncpor.polarops.service.ForecastingService;
import in.gov.moes.ncpor.polarops.dto.InventoryAdjustmentRequest;
import in.gov.moes.ncpor.polarops.model.InventoryTransaction;
import org.springframework.security.core.Authentication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;
@RestController
@RequestMapping("/api/v1/inventory")
@RequiredArgsConstructor
public class InventoryController {
    private final InventoryService inventoryService;
    private final ForecastingService forecastingService;
    @GetMapping
    public ResponseEntity<List<InventoryItem>> getAll() {
        return ResponseEntity.ok(inventoryService.getAll());
    }
    @GetMapping("/{id}")
    public ResponseEntity<InventoryItem> getById(@PathVariable Long id) {
        InventoryItem item = inventoryService.getById(id);
        return item != null ? ResponseEntity.ok(item) : ResponseEntity.notFound().build();
    }
    @PostMapping("/{id}/forecast")
    public ResponseEntity<ForecastResponse> getForecast(@PathVariable Long id) {
        InventoryItem item = inventoryService.getById(id);
        if(item != null) return ResponseEntity.ok(forecastingService.forecastInventory(item));
        return ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<InventoryItem> create(@RequestBody InventoryItem item) {
        return ResponseEntity.ok(inventoryService.save(item));
    }

    @PutMapping("/{id}")
    public ResponseEntity<InventoryItem> update(@PathVariable Long id, @RequestBody InventoryItem item) {
        if(inventoryService.getById(id) == null) return ResponseEntity.notFound().build();
        item.setItemId(id);
        return ResponseEntity.ok(inventoryService.save(item));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        inventoryService.delete(id);
        return ResponseEntity.ok().build();
    }
    @GetMapping("/{id}/transactions")
    public ResponseEntity<List<InventoryTransaction>> transactions(@PathVariable Long id) {
        return inventoryService.getById(id) == null ? ResponseEntity.notFound().build() : ResponseEntity.ok(inventoryService.getTransactions(id));
    }
    @PostMapping("/{id}/transactions")
    public ResponseEntity<?> adjust(@PathVariable Long id, @RequestBody InventoryAdjustmentRequest request, Authentication authentication) {
        try { return ResponseEntity.ok(inventoryService.adjust(id, request, authentication.getName())); }
        catch (IllegalArgumentException e) { return ResponseEntity.badRequest().body(java.util.Map.of("message", e.getMessage())); }
        catch (IllegalStateException e) { return ResponseEntity.status(409).body(java.util.Map.of("message", e.getMessage())); }
    }
}

package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "inventory_items")
public class InventoryItem {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long itemId;
    private String name;
    private String category;
    private Integer quantityAvailable;
    private Integer minimumStockLevel;
    private String unit;
    private String location;
    private String station;
    private LocalDate expiryDate;
    private Double dailyConsumptionRate; // e.g. units consumed per day

    @Transient
    public String getDerivedStatus() {
        int quantity = quantityAvailable == null ? 0 : quantityAvailable;
        int minimum = minimumStockLevel == null ? 0 : minimumStockLevel;
        if (quantity <= 0) return "OUT_OF_STOCK";
        if (quantity <= minimum / 2) return "CRITICAL";
        if (quantity <= minimum) return "LOW";
        return "NORMAL";
    }

    @Transient
    public Double getEstimatedDaysRemaining() {
        if (dailyConsumptionRate == null || dailyConsumptionRate <= 0 || quantityAvailable == null) return null;
        return quantityAvailable / dailyConsumptionRate;
    }

    @Transient
    public LocalDate getEstimatedDepletionDate() {
        if (dailyConsumptionRate != null && dailyConsumptionRate > 0 && quantityAvailable > 0) {
            int daysLeft = (int) (quantityAvailable / dailyConsumptionRate);
            return LocalDate.now().plusDays(daysLeft);
        }
        return null;
    }
}

package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "inventory_consumption_history")
public class InventoryConsumptionHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "inventory_item_id")
    private InventoryItem inventoryItem;

    private Integer quantityConsumed;
    private LocalDate consumptionDate;
    private Integer personnelCount;
    private String season;
    private String notes;
}
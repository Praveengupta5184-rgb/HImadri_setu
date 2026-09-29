package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity @Table(name = "inventory_transactions")
public class InventoryTransaction {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(optional = false) @JoinColumn(name = "inventory_item_id")
    private InventoryItem inventoryItem;
    private String transactionType;
    private Integer quantity;
    private String source;
    private String destination;
    private String performedBy;
    private LocalDateTime occurredAt;
    private String reference;
    @Column(length = 1000) private String notes;
}

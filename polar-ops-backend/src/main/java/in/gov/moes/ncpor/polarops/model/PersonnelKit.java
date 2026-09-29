package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity @Table(name = "personnel_kits")
public class PersonnelKit {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(optional = false) @JoinColumn(name = "personnel_id")
    private Personnel personnel;
    @ManyToOne @JoinColumn(name = "inventory_item_id")
    private InventoryItem inventoryItem;
    private String itemName;
    private String category;
    private Integer quantity;
    private String unit;
    private LocalDate issueDate;
    private LocalDate expectedReturnDate;
    private String returnStatus;
    private String issuedBy;
    @Column(length = 1000) private String notes;
}

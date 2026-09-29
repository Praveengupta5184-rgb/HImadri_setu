package in.gov.moes.ncpor.polarops.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class KitIssueRequest {
    private Long inventoryItemId;
    private String itemName;
    private String category;
    private Integer quantity;
    private String unit;
    private LocalDate expectedReturnDate;
    private String notes;
}

package in.gov.moes.ncpor.polarops.dto;

import lombok.Data;

@Data
public class InventoryAdjustmentRequest {
    private Integer quantity;
    private String transactionType;
    private String destination;
    private String reference;
    private String notes;
}

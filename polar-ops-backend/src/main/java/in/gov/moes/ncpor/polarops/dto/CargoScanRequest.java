package in.gov.moes.ncpor.polarops.dto;

import lombok.Data;

@Data
public class CargoScanRequest {
    private Double latitude;
    private Double longitude;
    private String timestamp;
    private String source;
    private String remarks;
}

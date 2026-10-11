package in.gov.moes.ncpor.polarops.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CargoTrackingEventDto {
    private Long id;
    private Long cargoId;
    private String previousStatus;
    private String newStatus;
    private String location;
    private Double latitude;
    private Double longitude;
    private String eventType;
    private String performedBy;
    private String remarks;
    private LocalDateTime timestamp;
}

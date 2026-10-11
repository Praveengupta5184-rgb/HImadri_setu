package in.gov.moes.ncpor.polarops.dto;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class CargoDto {
    private Long id;
    private String cargoId;
    private String name;
    private String description;
    
    private Long expeditionId;
    private Long teamId;
    private String ownerOrganization;
    
    private String origin;
    private String destination;
    
    private Integer quantity;
    private Double weight;
    private String dimensions;
    private String category;
    
    private String priority;
    
    private String currentStatus;
    
    private Boolean hazardousStatus;
    private String handlingRequirements;
    private String specialInstructions;
    
    private LocalDate expectedDeliveryDate;
    private LocalDate actualDeliveryDate;
    
    private String currentLocation;
    private Double latitude;
    private Double longitude;
    private LocalDateTime lastLocationUpdate;
    
    private String trackerId;
    private String qrCode;
    
    private Integer riskScore;
    private String createdBy;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

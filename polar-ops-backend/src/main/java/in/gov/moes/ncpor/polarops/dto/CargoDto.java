package in.gov.moes.ncpor.polarops.dto;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class CargoDto {
    private Long id;
    private String cargoId;
    private Long expeditionId;
    private String ownerOrganization;
    private String projectName;
    private String destination;
    private Integer packageNumber;
    private Integer totalPackages;
    private Double weight;
    private String dimensions;
    private String category;
    private Boolean hazardousStatus;
    private String storageConditions;
    private String currentStatus;
    private LocalDate expectedDeliveryDate;
    private Integer riskScore;
    private LocalDateTime createdAt;
}

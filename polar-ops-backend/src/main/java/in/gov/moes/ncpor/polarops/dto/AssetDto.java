package in.gov.moes.ncpor.polarops.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class AssetDto {
    private Long id;
    private String assetTag;
    private String name;
    private String category;
    private String description;
    private String serialNumber;
    private String manufacturer;
    private String model;
    private Integer quantity;
    private String status;
    private String condition;
    private String criticality;
    private String location;
    private LocalDate purchaseDate;
    private Double purchaseCost;
    private LocalDate lastMaintenanceDate;
    private LocalDate nextMaintenanceDate;
    private Long missionId;
    private Long stationId;
    private Long personnelId;
    private String personnelName;
    private Long userId;
    private String createdAt;
    private String updatedAt;
}
package in.gov.moes.ncpor.polarops.model;
import in.gov.moes.ncpor.polarops.model.cargo.CargoStatus;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "cargo_packages")
public class CargoPackage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
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
    
    @Enumerated(EnumType.STRING)
    private CargoStatus currentStatus;
    
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

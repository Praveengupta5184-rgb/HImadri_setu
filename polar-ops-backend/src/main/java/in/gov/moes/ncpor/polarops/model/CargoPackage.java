package in.gov.moes.ncpor.polarops.model;
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

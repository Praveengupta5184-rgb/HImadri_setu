package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "cargo_inspections")
public class CargoInspection {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "cargo_package_id")
    private CargoPackage cargoPackage;
    
    private String inspectorName; // Or system "AUTO-CV-SYSTEM"
    private String notes;
    private boolean passed;
    private LocalDateTime inspectionDate;
    
    // Audit & CV Fields
    private String imageUrl;
    private String modelName;
    private String modelVersion;
    private Double confidence;
    private String detectedObjects; // JSON string
    private Boolean damageDetected;
    private String riskContribution;
}

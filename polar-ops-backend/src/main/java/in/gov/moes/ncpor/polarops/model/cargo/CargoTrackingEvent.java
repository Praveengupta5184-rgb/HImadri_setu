package in.gov.moes.ncpor.polarops.model.cargo;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import in.gov.moes.ncpor.polarops.model.CargoPackage;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "cargo_tracking_events")
public class CargoTrackingEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cargo_id", nullable = false)
    private CargoPackage cargo;

    @Enumerated(EnumType.STRING)
    private CargoStatus previousStatus;

    @Enumerated(EnumType.STRING)
    private CargoStatus newStatus;

    private String location;
    private Double latitude;
    private Double longitude;
    
    private String eventType;
    private String performedBy;
    private String remarks;
    
    private LocalDateTime timestamp;
}

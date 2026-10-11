package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "cargo_events")
public class CargoEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "cargo_package_id")
    private CargoPackage cargoPackage;

    private String eventType;
    private String description;
    private String location;
    private String status;
    private LocalDateTime eventTime;
    private String recordedBy;
}
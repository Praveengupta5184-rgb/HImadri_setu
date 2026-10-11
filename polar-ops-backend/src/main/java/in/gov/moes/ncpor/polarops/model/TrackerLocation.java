package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "tracker_locations", indexes = {
    @Index(name = "idx_tracker_loc_tracker", columnList = "tracker_device_id"),
    @Index(name = "idx_tracker_loc_cargo", columnList = "cargo_id"),
    @Index(name = "idx_tracker_loc_client_uuid", columnList = "clientUuid", unique = true)
})
public class TrackerLocation {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String clientUuid; // For offline sync idempotency

    @ManyToOne(optional = false)
    @JoinColumn(name = "tracker_device_id")
    private TrackerDevice tracker;

    @ManyToOne
    @JoinColumn(name = "cargo_id")
    private CargoPackage cargo;

    @ManyToOne
    @JoinColumn(name = "mission_id")
    private Mission mission;

    private Double latitude;
    private Double longitude;
    private Double altitude;
    private Double accuracyMeters;
    private Double speed;
    private Double bearing;

    private LocalDateTime recordedAt;
    private String source;
}

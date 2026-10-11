package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "tracker_events", indexes = {
    @Index(name = "idx_tracker_evt_tracker", columnList = "tracker_device_id"),
    @Index(name = "idx_tracker_evt_client_id", columnList = "clientEventId", unique = true)
})
public class TrackerEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String clientEventId; // For offline sync idempotency

    @ManyToOne(optional = false)
    @JoinColumn(name = "tracker_device_id")
    private TrackerDevice tracker;

    @ManyToOne
    @JoinColumn(name = "cargo_id")
    private CargoPackage cargo;

    private String eventType;
    private String severity;
    private String metadata;
    private LocalDateTime timestamp;
}

package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "tracker_sessions")
public class TrackerSession {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "tracker_device_id")
    private TrackerDevice tracker;

    @ManyToOne
    @JoinColumn(name = "cargo_id")
    private CargoPackage cargo;

    @ManyToOne
    @JoinColumn(name = "mission_id")
    private Mission mission;

    private LocalDateTime startedAt;
    private LocalDateTime stoppedAt;

    @Column(nullable = false)
    private String status; // CREATED, ATTACHED, TRACKING, PAUSED, OFFLINE, STOPPED, DETACHED
}

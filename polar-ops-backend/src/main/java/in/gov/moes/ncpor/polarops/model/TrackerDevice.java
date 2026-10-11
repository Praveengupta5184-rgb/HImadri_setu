package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "tracker_devices", indexes = {
        @Index(name = "idx_tracker_device_id", columnList = "deviceId")
})
public class TrackerDevice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String deviceId;

    @ManyToOne
    @JoinColumn(name = "personnel_id")
    private Personnel personnel;

    private String platform;
    private String appVersion;
    private LocalDateTime registeredAt;
    private LocalDateTime lastHeartbeat;
    private Integer battery;
    private String networkStatus;

    @Column(nullable = false)
    private String status; // REGISTERED, ACTIVE, PAUSED, OFFLINE, REVOKED
}

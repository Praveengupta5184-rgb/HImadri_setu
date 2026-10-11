package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "mission_risk_snapshots")
public class MissionRiskSnapshot {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "mission_id")
    private Mission mission;

    private Integer missionRiskScore;
    private String riskLevel;
    private String factorContributions;
    private LocalDateTime snapshotTime;
    private String aiMode;
}
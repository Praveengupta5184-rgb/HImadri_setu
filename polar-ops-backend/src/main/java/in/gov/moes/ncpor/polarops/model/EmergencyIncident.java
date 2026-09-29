package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "emergency_incidents")
public class EmergencyIncident {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long incidentId;
    private String type;
    private String location;
    private String severity;
    private String status;
    private LocalDateTime reportedAt;
    private String reportedBy;
    private String responseTeam;
    @ManyToOne @JoinColumn(name = "mission_id")
    private Mission mission;
    
    @Column(columnDefinition = "TEXT")
    private String description;
    
    @Column(columnDefinition = "TEXT")
    private String resolution;
    
    @OneToMany(cascade = CascadeType.ALL, orphanRemoval = true)
    @JoinColumn(name = "incident_id")
    private java.util.List<IncidentAudit> auditHistory = new java.util.ArrayList<>();
}

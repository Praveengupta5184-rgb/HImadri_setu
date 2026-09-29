package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "incident_audits")
public class IncidentAudit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String action; // e.g. "Status changed to RESPONDING", "Equipment dispatched"
    private String performedBy;
    private LocalDateTime timestamp;
}

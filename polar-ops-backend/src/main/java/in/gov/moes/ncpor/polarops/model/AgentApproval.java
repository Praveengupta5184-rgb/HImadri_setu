package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "agent_approvals")
public class AgentApproval {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long recommendationId;
    private String approvedBy;
    private LocalDateTime approvedAt;
    private String decision;
    private String comment;
}
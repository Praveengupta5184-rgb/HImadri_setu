package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "agent_executions")
public class AgentExecution {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long missionId;
    private String executionPhase;
    private String observations;
    private String analysis;
    private String predictions;
    private String explanations;
    private String recommendations;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    private String status;
    private String aiMode;
}
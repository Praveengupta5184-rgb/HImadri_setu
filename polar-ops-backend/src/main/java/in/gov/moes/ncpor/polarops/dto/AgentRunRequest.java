package in.gov.moes.ncpor.polarops.dto;
import lombok.*;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AgentRunRequest {
    private Long missionId;
    private String triggeredBy;
}

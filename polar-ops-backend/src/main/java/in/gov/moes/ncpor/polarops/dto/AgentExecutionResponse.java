package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AgentExecutionResponse {
    private Long executionId;
    private String missionId;
    private String status;
    private String phase;
    private String observations;
    private String analysis;
    private String predictions;
    private String explanations;
    private List<AgentRecommendation> recommendations;
    private String startedAt;
    private String completedAt;
    private String aiMode;
    private String message;
}
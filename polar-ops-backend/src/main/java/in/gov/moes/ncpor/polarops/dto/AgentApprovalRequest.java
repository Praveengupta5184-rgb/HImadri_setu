package in.gov.moes.ncpor.polarops.dto;
import lombok.*;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AgentApprovalRequest {
    private String decision; // APPROVED, REJECTED
    private String comment;
    private String approvedBy;
}

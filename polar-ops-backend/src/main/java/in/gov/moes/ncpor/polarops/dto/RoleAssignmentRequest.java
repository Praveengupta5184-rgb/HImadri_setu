package in.gov.moes.ncpor.polarops.dto;
import in.gov.moes.ncpor.polarops.model.Role;
import lombok.*;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class RoleAssignmentRequest {
    private Role role;
}

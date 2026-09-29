package in.gov.moes.ncpor.polarops.dto;
import in.gov.moes.ncpor.polarops.model.Role;
import lombok.*;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class RegisterRequest {
    private String email;
    private String password;
    private String name;
    private Role role;
}

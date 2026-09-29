package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "notifications")
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String title;
    private String message;
    private String type; // e.g. "ALERT", "INFO"
    private String severity;
    private LocalDateTime createdAt;
    private Boolean isRead;
}

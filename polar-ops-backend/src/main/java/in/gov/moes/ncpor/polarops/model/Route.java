package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "routes")
public class Route {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String origin;
    private String destination;
    
    @Column(columnDefinition = "TEXT")
    private String waypoints; // JSON list of coordinates
    
    private String status;
    private LocalDateTime eta;
    private String source;
    private Boolean isSimulation;
}

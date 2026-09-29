package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "personnel_movements")
public class PersonnelMovement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "personnel_id")
    private Personnel personnel;
    
    private String fromLocation;
    private String toLocation;
    private LocalDateTime movementTime;
    private String transportMethod;
}

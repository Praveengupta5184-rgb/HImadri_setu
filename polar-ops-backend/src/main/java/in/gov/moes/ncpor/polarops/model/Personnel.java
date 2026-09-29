package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "personnel")
public class Personnel {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String role;
    private String organization;
    private String medicalClearanceStatus;
    
    private String currentLocation;
    private String destination;
    private String movementStatus; // AT_BASE, MOBILIZING, IN_TRANSIT, AT_STATION, RETURNING
    
    @ManyToOne
    @JoinColumn(name = "expedition_id")
    private Expedition expedition;
    
    @OneToOne(mappedBy = "personnel")
    private User user;
}

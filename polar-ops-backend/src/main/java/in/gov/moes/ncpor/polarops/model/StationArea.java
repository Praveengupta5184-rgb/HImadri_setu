package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "station_areas")
public class StationArea {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "station_id")
    private Station station;
    
    private String name;
    private String type;
    private Integer floorLevel;
    private String safetyStatus;
}

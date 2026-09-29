package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "stations")
public class Station {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String location;
    private Double latitude;
    private Double longitude;
    private String coordinatesSource;
    private String type; // e.g. "RESEARCH", "LOGISTICS"
    private String status;
    private Integer currentCapacity;
    private Integer maxCapacity;
}

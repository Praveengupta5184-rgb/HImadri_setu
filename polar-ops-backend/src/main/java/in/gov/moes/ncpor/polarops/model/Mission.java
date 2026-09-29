package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor @Entity
@Table(name="missions", uniqueConstraints=@UniqueConstraint(columnNames="missionCode"))
public class Mission {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id;
 @Column(nullable=false, unique=true) private String missionCode;
 @ManyToOne(optional=false) @JoinColumn(name="expedition_id") private Expedition expedition;
 @Column(nullable=false) private String missionName;
 @Column(length=2000) private String objective;
 private String targetZone; private LocalDate startDate; private LocalDate endDate; private String status;
 private String createdBy; private LocalDateTime createdAt; private LocalDateTime updatedAt;
}

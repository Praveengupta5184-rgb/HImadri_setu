package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor @Entity
@Table(name="mission_teams", uniqueConstraints=@UniqueConstraint(columnNames="teamCode"))
public class MissionTeam { @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id; @Column(nullable=false,unique=true) private String teamCode; private String teamName; @ManyToOne(optional=false) @JoinColumn(name="mission_id") private Mission mission; @ManyToOne @JoinColumn(name="leader_personnel_id") private Personnel teamLeader; private String status; private LocalDateTime createdAt; private LocalDateTime updatedAt; }

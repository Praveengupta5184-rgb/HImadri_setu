package in.gov.moes.ncpor.polarops.model;
import jakarta.persistence.*;
import lombok.*;
import java.time.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor @Entity
@Table(name="mission_members", uniqueConstraints=@UniqueConstraint(columnNames={"mission_id","personnel_id"}))
public class MissionMember { @Id @GeneratedValue(strategy=GenerationType.IDENTITY) private Long id; @ManyToOne(optional=false) @JoinColumn(name="mission_id") private Mission mission; @ManyToOne(optional=false) @JoinColumn(name="team_id") private MissionTeam team; @ManyToOne(optional=false) @JoinColumn(name="personnel_id") private Personnel personnel; private String roleInTeam; private String membershipStatus; private LocalDateTime joinedAt; private LocalDateTime removedAt; }

package in.gov.moes.ncpor.polarops.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeamViewDto {
    private String teamCode;
    private String teamName;
    private String missionCode;
    private String missionName;
    private String teamLeadName;
    private String status;
    private int memberCount;
    private List<TeamMemberDto> members;
}

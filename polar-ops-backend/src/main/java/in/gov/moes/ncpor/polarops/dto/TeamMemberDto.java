package in.gov.moes.ncpor.polarops.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TeamMemberDto {
    private Long personnelId;
    private String name;
    private String role;
    private String assignmentStatus;
    private String availability;
    private LocationDto location;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class LocationDto {
        private Double latitude;
        private Double longitude;
        private String updatedAt;
    }
}

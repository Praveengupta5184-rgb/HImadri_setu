package in.gov.moes.ncpor.polarops.dto;

import lombok.Builder;
import lombok.Value;
import java.time.LocalDateTime;

@Value @Builder
public class PersonnelLocationResponse {
    Long id;
    Long personnelId;
    String personnelName;
    Double latitude;
    Double longitude;
    Double accuracyMeters;
    LocalDateTime timestamp;
    String source;
    String movementStatus;
    String freshness;
    Long ageSeconds;
}

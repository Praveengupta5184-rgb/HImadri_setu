package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.dto.PersonnelLocationResponse;
import in.gov.moes.ncpor.polarops.model.PersonnelLocation;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.time.Duration;
import java.time.LocalDateTime;

@Service
public class LocationFreshnessService {
    @Value("${polarops.location.freshness.live-seconds:60}") private long liveSeconds;
    @Value("${polarops.location.freshness.recent-seconds:300}") private long recentSeconds;
    @Value("${polarops.location.freshness.stale-seconds:1800}") private long staleSeconds;

    public PersonnelLocationResponse toResponse(PersonnelLocation location, boolean trackingClosed) {
        long age = Math.max(0, Duration.between(location.getRecordedAt(), LocalDateTime.now()).getSeconds());
        String freshness = trackingClosed ? "OFFLINE" : classify(age);
        return PersonnelLocationResponse.builder()
                .id(location.getId()).personnelId(location.getPersonnel().getId()).personnelName(location.getPersonnel().getName())
                .latitude(location.getLatitude()).longitude(location.getLongitude()).accuracyMeters(location.getAccuracyMeters())
                .timestamp(location.getRecordedAt()).source(location.getSource()).movementStatus(location.getMovementStatus())
                .freshness(freshness).ageSeconds(age).build();
    }

    private String classify(long ageSeconds) {
        if (ageSeconds <= liveSeconds) return "LIVE";
        if (ageSeconds <= recentSeconds) return "RECENT";
        if (ageSeconds <= staleSeconds) return "STALE";
        return "OFFLINE";
    }
}

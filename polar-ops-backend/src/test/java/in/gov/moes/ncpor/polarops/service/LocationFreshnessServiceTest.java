package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.model.PersonnelLocation;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;
import java.time.LocalDateTime;
import static org.assertj.core.api.Assertions.assertThat;

class LocationFreshnessServiceTest {
    private LocationFreshnessService service;

    @BeforeEach
    void setUp() {
        service = new LocationFreshnessService();
        ReflectionTestUtils.setField(service, "liveSeconds", 60L);
        ReflectionTestUtils.setField(service, "recentSeconds", 300L);
        ReflectionTestUtils.setField(service, "staleSeconds", 1800L);
    }

    @Test void classifiesLiveRecentStaleAndOfflineFromStoredTimestamp() {
        assertThat(service.toResponse(locationAtSecondsAgo(30), false).getFreshness()).isEqualTo("LIVE");
        assertThat(service.toResponse(locationAtSecondsAgo(120), false).getFreshness()).isEqualTo("RECENT");
        assertThat(service.toResponse(locationAtSecondsAgo(600), false).getFreshness()).isEqualTo("STALE");
        assertThat(service.toResponse(locationAtSecondsAgo(1900), false).getFreshness()).isEqualTo("OFFLINE");
    }

    @Test void closedMissionForcesHistoricalLocationOfflineWithoutChangingTimestamp() {
        PersonnelLocation location = locationAtSecondsAgo(5);
        var response = service.toResponse(location, true);
        assertThat(response.getFreshness()).isEqualTo("OFFLINE");
        assertThat(response.getTimestamp()).isEqualTo(location.getRecordedAt());
        assertThat(response.getLatitude()).isEqualTo(location.getLatitude());
    }

    private PersonnelLocation locationAtSecondsAgo(long seconds) {
        return PersonnelLocation.builder().id(1L).personnel(Personnel.builder().id(7L).name("Test Member").build())
                .latitude(-70.7).longitude(11.7).recordedAt(LocalDateTime.now().minusSeconds(seconds))
                .source("DEVICE").movementStatus("AT_STATION").build();
    }
}

package in.gov.moes.ncpor.polarops.security;

import in.gov.moes.ncpor.polarops.model.Mission;
import in.gov.moes.ncpor.polarops.repository.MissionRepository;
import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import java.util.List;
import java.util.Optional;
import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

class MissionClosureFilterTest {
    @Test void blocksMissionMutationButAllowsHistoricalGet() throws Exception {
        MissionRepository repository = mock(MissionRepository.class);
        when(repository.findByMissionCode("POLAR-2026-001")).thenReturn(Optional.of(Mission.builder().missionCode("POLAR-2026-001").status("CLOSED").build()));
        MissionClosureFilter filter = new MissionClosureFilter(repository);
        FilterChain chain = mock(FilterChain.class);

        MockHttpServletRequest post = new MockHttpServletRequest("POST", "/api/v1/missions/POLAR-2026-001/teams");
        MockHttpServletResponse blocked = new MockHttpServletResponse();
        filter.doFilter(post, blocked, chain);
        assertThat(blocked.getStatus()).isEqualTo(409);
        assertThat(blocked.getContentAsString()).contains("Mission is closed");
        verifyNoInteractions(chain);

        MockHttpServletRequest get = new MockHttpServletRequest("GET", "/api/v1/missions/POLAR-2026-001/locations");
        MockHttpServletResponse permitted = new MockHttpServletResponse();
        filter.doFilter(get, permitted, chain);
        verify(chain).doFilter(get, permitted);
    }

    @Test void blocksEveryPhase17OperationalMutationForClosedMission() throws Exception {
        MissionRepository repository = mock(MissionRepository.class);
        when(repository.findByMissionCode("POLAR-2026-001")).thenReturn(Optional.of(Mission.builder()
                .missionCode("POLAR-2026-001").status("CLOSED").build()));
        MissionClosureFilter filter = new MissionClosureFilter(repository);

        List<String> mutationPaths = List.of(
                "/teams",
                "/members",
                "/targets", "/targets/14",
                "/assignments", "/assignments/14",
                "/personnel/24/location");
        List<String> methods = List.of("POST", "POST", "POST", "PUT", "POST", "PUT", "POST");

        for (int index = 0; index < mutationPaths.size(); index++) {
            FilterChain chain = mock(FilterChain.class);
            MockHttpServletRequest request = new MockHttpServletRequest(methods.get(index),
                    "/api/v1/missions/POLAR-2026-001" + mutationPaths.get(index));
            MockHttpServletResponse response = new MockHttpServletResponse();

            filter.doFilter(request, response, chain);

            assertThat(response.getStatus()).isEqualTo(409);
            assertThat(response.getContentAsString()).contains("Mission is closed");
            verifyNoInteractions(chain);
        }
    }
}

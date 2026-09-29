package in.gov.moes.ncpor.polarops.security;

import in.gov.moes.ncpor.polarops.repository.MissionRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;
import java.io.IOException;

/** Blocks all mission operational mutations after closure while preserving history reads. */
@Component
@RequiredArgsConstructor
public class MissionClosureFilter extends OncePerRequestFilter {
    private final MissionRepository missionRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {
        String path = request.getRequestURI();
        boolean mutation = !HttpMethod.GET.matches(request.getMethod()) && !HttpMethod.OPTIONS.matches(request.getMethod());
        String prefix = "/api/v1/missions/";
        if (mutation && path.startsWith(prefix)) {
            String suffix = path.substring(prefix.length());
            String code = suffix.split("/")[0];
            if (!code.isBlank() && !"close".equals(code)) {
                var mission = missionRepository.findByMissionCode(code);
                if (mission.isPresent() && ("CLOSED".equals(mission.get().getStatus()) || "COMPLETED".equals(mission.get().getStatus()))) {
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    response.setContentType("application/json");
                    response.getWriter().write("{\"message\":\"Mission is closed; operational mutations are not permitted.\"}");
                    return;
                }
            }
        }
        chain.doFilter(request, response);
    }
}

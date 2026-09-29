package in.gov.moes.ncpor.polarops.security;

import in.gov.moes.ncpor.polarops.service.AuditService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuditInterceptor implements HandlerInterceptor {

    @Autowired
    private AuditService auditService;

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        String method = request.getMethod();
        if ("POST".equals(method) || "PUT".equals(method) || "DELETE".equals(method)) {
            String user = "anonymous";
            if (SecurityContextHolder.getContext().getAuthentication() != null) {
                user = SecurityContextHolder.getContext().getAuthentication().getName();
            }
            String action = method;
            String entity = request.getRequestURI();
            auditService.logAction(user, action, entity);
        }
    }
}

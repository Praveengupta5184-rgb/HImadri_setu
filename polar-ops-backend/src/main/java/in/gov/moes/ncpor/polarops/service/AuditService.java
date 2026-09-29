package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.AuditLog;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
@Service
public class AuditService {
    private final List<AuditLog> logs = Collections.synchronizedList(new ArrayList<>());
    private long idCounter = 1;
    public void logAction(String user, String action, String entity) {
        logs.add(AuditLog.builder().id(idCounter++).user(user).action(action).entity(entity).timestamp(LocalDateTime.now()).build());
    }
    public List<AuditLog> getLogs() { return new ArrayList<>(logs); }
}

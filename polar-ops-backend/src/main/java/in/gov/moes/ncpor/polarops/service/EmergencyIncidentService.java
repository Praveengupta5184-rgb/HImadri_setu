package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.EmergencyIncident;
import in.gov.moes.ncpor.polarops.model.IncidentAudit;
import in.gov.moes.ncpor.polarops.repository.EmergencyIncidentRepository;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class EmergencyIncidentService {
    private final EmergencyIncidentRepository emergencyIncidentRepository;

    public List<EmergencyIncident> getAll() {
        return emergencyIncidentRepository.findAll();
    }

    public EmergencyIncident getById(Long id) {
        return emergencyIncidentRepository.findById(id).orElse(null);
    }

    public EmergencyIncident createIncident(EmergencyIncident incident) {
        if (incident.getReportedAt() == null) {
            incident.setReportedAt(LocalDateTime.now());
        }
        if (incident.getStatus() == null) {
            incident.setStatus("REPORTED");
        }
        
        IncidentAudit initialAudit = IncidentAudit.builder()
                .action("Incident Created and marked as " + incident.getStatus())
                .performedBy(incident.getReportedBy() != null ? incident.getReportedBy() : "SYSTEM")
                .timestamp(LocalDateTime.now())
                .build();
        
        incident.getAuditHistory().add(initialAudit);
        
        return emergencyIncidentRepository.save(incident);
    }

    public EmergencyIncident updateStatus(Long id, String status, String performedBy, String notes) {
        EmergencyIncident incident = getById(id);
        if (incident == null) return null;
        
        incident.setStatus(status);
        if (notes != null && !notes.isEmpty()) {
            if ("RESOLVED".equals(status)) {
                incident.setResolution(notes);
            }
        }
        
        IncidentAudit audit = IncidentAudit.builder()
                .action("Status changed to " + status + (notes != null ? " - " + notes : ""))
                .performedBy(performedBy)
                .timestamp(LocalDateTime.now())
                .build();
                
        incident.getAuditHistory().add(audit);
        return emergencyIncidentRepository.save(incident);
    }
}

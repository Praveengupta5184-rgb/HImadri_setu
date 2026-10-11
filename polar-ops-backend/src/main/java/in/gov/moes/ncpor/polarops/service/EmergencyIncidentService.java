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
    private final NotificationService notificationService;

    public java.util.Map<String, Object> getDashboardMetrics() {
        List<EmergencyIncident> all = emergencyIncidentRepository.findAll();
        long active = all.stream().filter(i -> !("RESOLVED".equals(i.getStatus()) || "CLOSED".equals(i.getStatus()) || "CANCELLED".equals(i.getStatus()))).count();
        long highPriority = all.stream().filter(i -> !("RESOLVED".equals(i.getStatus()) || "CLOSED".equals(i.getStatus()) || "CANCELLED".equals(i.getStatus())) && ("HIGH".equals(i.getSeverity()) || "CRITICAL".equals(i.getSeverity()))).count();
        long pendingResponse = all.stream().filter(i -> "REPORTED".equals(i.getStatus()) || "ACKNOWLEDGED".equals(i.getStatus())).count();
        long resolvedToday = all.stream().filter(i -> "RESOLVED".equals(i.getStatus()) && i.getResolvedAt() != null && i.getResolvedAt().toLocalDate().equals(LocalDateTime.now().toLocalDate())).count();
        long personnelAtRisk = all.stream().filter(i -> !("RESOLVED".equals(i.getStatus()) || "CLOSED".equals(i.getStatus()) || "CANCELLED".equals(i.getStatus())) && i.getPeopleAffected() != null).mapToInt(EmergencyIncident::getPeopleAffected).sum();
        long medicalResponses = all.stream().filter(i -> !("RESOLVED".equals(i.getStatus()) || "CLOSED".equals(i.getStatus()) || "CANCELLED".equals(i.getStatus())) && "MEDICAL".equalsIgnoreCase(i.getType())).count();
        
        java.util.Map<String, Object> metrics = new java.util.HashMap<>();
        metrics.put("activeEmergencies", active);
        metrics.put("highPriority", highPriority);
        metrics.put("pendingResponse", pendingResponse);
        metrics.put("resolvedToday", resolvedToday);
        metrics.put("personnelAtRisk", personnelAtRisk);
        metrics.put("medicalResponses", medicalResponses);
        return metrics;
    }

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
        if (incident.getCreatedAt() == null) {
            incident.setCreatedAt(LocalDateTime.now());
        }
        incident.setUpdatedAt(LocalDateTime.now());
        if (incident.getStatus() == null) {
            incident.setStatus("REPORTED");
        }
        if (incident.getEmergencyId() == null) {
            long count = emergencyIncidentRepository.count();
            incident.setEmergencyId(String.format("EMG-%d-%04d", LocalDateTime.now().getYear(), count + 1));
        }
        
        IncidentAudit initialAudit = IncidentAudit.builder()
                .action("Incident Created and marked as " + incident.getStatus())
                .performedBy(incident.getReportedBy() != null ? incident.getReportedBy() : "SYSTEM")
                .timestamp(LocalDateTime.now())
                .build();
        
        incident.getAuditHistory().add(initialAudit);
        
        incident = emergencyIncidentRepository.save(incident);
        
        // Broadcast notification
        notificationService.sendNotification(
            null, // broadcast to all
            "EMERGENCY",
            incident.getSeverity() != null ? incident.getSeverity() : "CRITICAL",
            "New Emergency Incident",
            "Emergency reported: " + incident.getType() + " at " + incident.getLocation(),
            String.valueOf(incident.getIncidentId())
        );
        
        return incident;
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
        if ("RESOLVED".equals(status) && incident.getResolvedAt() == null) {
            incident.setResolvedAt(LocalDateTime.now());
            incident.setResolvedBy(performedBy);
        }
        
        IncidentAudit audit = IncidentAudit.builder()
                .action("Status changed to " + status + (notes != null ? " - " + notes : ""))
                .performedBy(performedBy)
                .timestamp(LocalDateTime.now())
                .build();
                
        incident.getAuditHistory().add(audit);
        incident = emergencyIncidentRepository.save(incident);
        
        // Broadcast update
        notificationService.sendNotification(
            null, // broadcast to all
            "EMERGENCY_UPDATE",
            incident.getSeverity() != null ? incident.getSeverity() : "INFO",
            "Emergency Status Updated",
            "Incident " + incident.getIncidentId() + " is now " + status,
            String.valueOf(incident.getIncidentId())
        );
        
        return incident;
    }
}

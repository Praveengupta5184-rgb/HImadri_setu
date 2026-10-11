package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.*;
import in.gov.moes.ncpor.polarops.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TrackerService {
    private final TrackerDeviceRepository deviceRepo;
    private final TrackerSessionRepository sessionRepo;
    private final TrackerLocationRepository locationRepo;
    private final TrackerEventRepository eventRepo;
    private final PersonnelRepository personnelRepo;
    private final CargoRepository cargoRepo;

    @Transactional
    public TrackerDevice registerDevice(Map<String, Object> payload) {
        String deviceId = (String) payload.get("deviceId");
        String appVersion = (String) payload.get("appVersion");
        Integer personnelIdRaw = (Integer) payload.get("personnelId");
        
        TrackerDevice device = deviceRepo.findByDeviceId(deviceId).orElseGet(() -> {
            TrackerDevice newDevice = new TrackerDevice();
            newDevice.setDeviceId(deviceId);
            newDevice.setRegisteredAt(LocalDateTime.now());
            newDevice.setStatus("REGISTERED");
            return newDevice;
        });

        if (personnelIdRaw != null) {
            personnelRepo.findById(personnelIdRaw.longValue()).ifPresent(device::setPersonnel);
        }

        device.setAppVersion(appVersion);
        device.setPlatform("ANDROID");
        device.setLastHeartbeat(LocalDateTime.now());
        
        return deviceRepo.save(device);
    }

    @Transactional
    public TrackerSession attachCargo(String deviceId, Long cargoId) {
        TrackerDevice device = deviceRepo.findByDeviceId(deviceId)
                .orElseThrow(() -> new RuntimeException("Device not found"));

        CargoPackage cargo = cargoRepo.findById(cargoId)
                .orElseThrow(() -> new RuntimeException("Cargo not found"));

        // Check if tracker already attached
        Optional<TrackerSession> activeSession = sessionRepo.findByTracker_DeviceIdAndStatusIn(
                deviceId, List.of("ATTACHED", "TRACKING", "PAUSED"));
        if (activeSession.isPresent()) {
            throw new RuntimeException("Tracker is currently attached to CARGO-" + activeSession.get().getCargo().getId());
        }

        TrackerSession session = new TrackerSession();
        session.setTracker(device);
        session.setCargo(cargo);
        session.setStartedAt(LocalDateTime.now());
        session.setStatus("ATTACHED");

        device.setStatus("ACTIVE");
        deviceRepo.save(device);

        return sessionRepo.save(session);
    }

    @Transactional
    public void ingestLocations(String deviceId, List<Map<String, Object>> locations) {
        TrackerDevice device = deviceRepo.findByDeviceId(deviceId)
                .orElseThrow(() -> new RuntimeException("Device not found"));
        
        Optional<TrackerSession> sessionOpt = sessionRepo.findByTracker_DeviceIdAndStatusIn(
                deviceId, List.of("ATTACHED", "TRACKING", "PAUSED"));

        CargoPackage cargo = sessionOpt.map(TrackerSession::getCargo).orElse(null);

        for (Map<String, Object> locData : locations) {
            String clientUuid = (String) locData.get("clientUuid");
            if (locationRepo.findByClientUuid(clientUuid).isPresent()) {
                continue; // Idempotent
            }
            TrackerLocation loc = new TrackerLocation();
            loc.setClientUuid(clientUuid);
            loc.setTracker(device);
            loc.setCargo(cargo);
            loc.setLatitude(((Number) locData.get("latitude")).doubleValue());
            loc.setLongitude(((Number) locData.get("longitude")).doubleValue());
            if (locData.get("altitude") != null) loc.setAltitude(((Number) locData.get("altitude")).doubleValue());
            if (locData.get("speed") != null) loc.setSpeed(((Number) locData.get("speed")).doubleValue());
            if (locData.get("accuracy") != null) loc.setAccuracyMeters(((Number) locData.get("accuracy")).doubleValue());
            
            loc.setRecordedAt(LocalDateTime.parse((String) locData.get("timestamp")));
            loc.setSource("ANDROID_GPS");
            locationRepo.save(loc);
        }

        device.setLastHeartbeat(LocalDateTime.now());
        deviceRepo.save(device);
    }

    @Transactional
    public void ingestEvents(String deviceId, List<Map<String, Object>> events) {
        TrackerDevice device = deviceRepo.findByDeviceId(deviceId)
                .orElseThrow(() -> new RuntimeException("Device not found"));

        Optional<TrackerSession> sessionOpt = sessionRepo.findByTracker_DeviceIdAndStatusIn(
                deviceId, List.of("ATTACHED", "TRACKING", "PAUSED"));

        CargoPackage cargo = sessionOpt.map(TrackerSession::getCargo).orElse(null);

        for (Map<String, Object> evtData : events) {
            String clientEventId = (String) evtData.get("clientEventId");
            if (eventRepo.findByClientEventId(clientEventId).isPresent()) {
                continue; // Idempotent
            }
            TrackerEvent evt = new TrackerEvent();
            evt.setClientEventId(clientEventId);
            evt.setTracker(device);
            evt.setCargo(cargo);
            evt.setEventType((String) evtData.get("eventType"));
            evt.setSeverity((String) evtData.get("severity"));
            evt.setMetadata((String) evtData.get("metadata"));
            evt.setTimestamp(LocalDateTime.parse((String) evtData.get("timestamp")));
            eventRepo.save(evt);
        }
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> getActiveTrackers() {
        return sessionRepo.findAll().stream()
            .filter(s -> List.of("ATTACHED", "TRACKING").contains(s.getStatus()))
            .map(s -> {
                // Find latest location for tracker
                Optional<TrackerLocation> latestLoc = locationRepo.findAll().stream()
                    .filter(loc -> loc.getTracker().getId().equals(s.getTracker().getId()))
                    .max((l1, l2) -> l1.getRecordedAt().compareTo(l2.getRecordedAt()));
                
                Map<String, Object> result = new java.util.HashMap<>();
                result.put("deviceId", s.getTracker().getDeviceId());
                result.put("cargoId", s.getCargo() != null ? s.getCargo().getId() : null);
                result.put("status", s.getStatus());
                result.put("latitude", latestLoc.map(TrackerLocation::getLatitude).orElse(null));
                result.put("longitude", latestLoc.map(TrackerLocation::getLongitude).orElse(null));
                result.put("lastSeen", latestLoc.map(l -> l.getRecordedAt().toString()).orElse(null));
                return result;
            }).toList();
    }
}

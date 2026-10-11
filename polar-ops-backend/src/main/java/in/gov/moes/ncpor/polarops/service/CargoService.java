package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.repository.CargoRepository;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CargoService {
    private final CargoRepository cargoRepository;
    private final in.gov.moes.ncpor.polarops.repository.CargoTrackingEventRepository trackingEventRepository;

    public List<CargoPackage> getAll() {
        return cargoRepository.findAll();
    }

    public CargoPackage getById(Long id) {
        return cargoRepository.findById(id).orElse(null);
    }

    public CargoPackage create(CargoPackage cargo) {
        if (cargo.getCreatedAt() == null) {
            cargo.setCreatedAt(LocalDateTime.now());
        }
        if (cargo.getQrCode() == null || cargo.getQrCode().isEmpty()) {
            cargo.setQrCode(cargo.getCargoId());
        }
        return cargoRepository.save(cargo);
    }

    public CargoPackage update(Long id, CargoPackage updatedCargo) {
        if (cargoRepository.existsById(id)) {
            updatedCargo.setId(id);
            updatedCargo.setUpdatedAt(LocalDateTime.now());
            return cargoRepository.save(updatedCargo);
        }
        return null;
    }

    public boolean delete(Long id) {
        if (cargoRepository.existsById(id)) {
            cargoRepository.deleteById(id);
            return true;
        }
        return false;
    }

    public CargoPackage updateStatus(Long id, in.gov.moes.ncpor.polarops.model.cargo.CargoStatus newStatus, String performedBy, String location, String remarks) {
        return cargoRepository.findById(id).map(cargo -> {
            in.gov.moes.ncpor.polarops.model.cargo.CargoStatus oldStatus = cargo.getCurrentStatus();
            cargo.setCurrentStatus(newStatus);
            cargo.setUpdatedAt(LocalDateTime.now());
            cargo.setCurrentLocation(location);
            
            in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent event = in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent.builder()
                .cargo(cargo)
                .previousStatus(oldStatus)
                .newStatus(newStatus)
                .location(location)
                .eventType("STATUS_UPDATE")
                .performedBy(performedBy)
                .remarks(remarks)
                .timestamp(LocalDateTime.now())
                .build();
            // Save tracking event
            trackingEventRepository.save(event);
            return cargoRepository.save(cargo);
        }).orElse(null);
    }

    public List<in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent> getTrackingHistory(Long id) {
        return trackingEventRepository.findByCargoIdOrderByTimestampDesc(id);
    }

    public CargoPackage recordScan(Long id, Double lat, Double lng, String source, String remarks, String performedBy) {
        return cargoRepository.findById(id).map(cargo -> {
            cargo.setLatitude(lat);
            cargo.setLongitude(lng);
            cargo.setLastLocationUpdate(LocalDateTime.now());
            cargo.setCurrentLocation(lat != null && lng != null ? String.format("%.4f, %.4f", lat, lng) : "Unknown");
            
            in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent event = in.gov.moes.ncpor.polarops.model.cargo.CargoTrackingEvent.builder()
                .cargo(cargo)
                .previousStatus(cargo.getCurrentStatus())
                .newStatus(cargo.getCurrentStatus())
                .location(cargo.getCurrentLocation())
                .eventType(source != null ? source : "QR_SCAN")
                .performedBy(performedBy)
                .remarks(remarks)
                .timestamp(LocalDateTime.now())
                .build();
                
            trackingEventRepository.save(event);
            return cargoRepository.save(cargo);
        }).orElse(null);
    }
}

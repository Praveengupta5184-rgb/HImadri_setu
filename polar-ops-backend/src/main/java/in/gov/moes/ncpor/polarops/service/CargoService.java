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
        return cargoRepository.save(cargo);
    }

    public CargoPackage update(Long id, CargoPackage updatedCargo) {
        if (cargoRepository.existsById(id)) {
            updatedCargo.setId(id);
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
}

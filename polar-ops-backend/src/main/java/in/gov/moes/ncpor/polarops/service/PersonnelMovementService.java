package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.PersonnelMovement;
import in.gov.moes.ncpor.polarops.repository.PersonnelMovementRepository;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PersonnelMovementService {
    private final PersonnelMovementRepository personnelMovementRepository;

    public List<PersonnelMovement> getAll() {
        return personnelMovementRepository.findAll();
    }

    public PersonnelMovement getById(Long id) {
        return personnelMovementRepository.findById(id).orElse(null);
    }

    public PersonnelMovement save(PersonnelMovement m) {
        return personnelMovementRepository.save(m);
    }

    public void delete(Long id) {
        personnelMovementRepository.deleteById(id);
    }
}

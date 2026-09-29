package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.repository.PersonnelRepository;
import org.springframework.stereotype.Service;
import lombok.RequiredArgsConstructor;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PersonnelService {
    private final PersonnelRepository personnelRepository;

    public List<Personnel> getAll() {
        return personnelRepository.findAll();
    }

    public Personnel getById(Long id) {
        return personnelRepository.findById(id).orElse(null);
    }

    public Personnel save(Personnel p) {
        return personnelRepository.save(p);
    }

    public void delete(Long id) {
        personnelRepository.deleteById(id);
    }
}

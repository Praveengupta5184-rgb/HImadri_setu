package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.model.PersonnelMovement;
import in.gov.moes.ncpor.polarops.service.PersonnelMovementService;
import in.gov.moes.ncpor.polarops.service.ValidationService;
import in.gov.moes.ncpor.polarops.service.ValidationService.ValidationResult;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/personnel-movements")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class PersonnelMovementController {
    private final PersonnelMovementService personnelMovementService;
    private final ValidationService validationService;

    @GetMapping
    public ResponseEntity<List<PersonnelMovement>> getAll() {
        return ResponseEntity.ok(personnelMovementService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<PersonnelMovement> getById(@PathVariable Long id) {
        PersonnelMovement m = personnelMovementService.getById(id);
        return m != null ? ResponseEntity.ok(m) : ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody PersonnelMovement m) {
        if (m.getPersonnel() == null || m.getPersonnel().getId() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "MISSING_PERSONNEL", "message", "Personnel reference is required"));
        }
        
        ValidationResult validation = validationService.validatePersonnelExists(m.getPersonnel().getId());
        if (!validation.valid()) {
            return ResponseEntity.status(404)
                    .body(Map.of("error", validation.errorCode(), "message", validation.message()));
        }
        
        return ResponseEntity.ok(personnelMovementService.save(m));
    }

    @PutMapping("/{id}")
    public ResponseEntity<PersonnelMovement> update(@PathVariable Long id, @RequestBody PersonnelMovement m) {
        if (personnelMovementService.getById(id) == null) {
            return ResponseEntity.notFound().build();
        }
        m.setId(id);
        return ResponseEntity.ok(personnelMovementService.save(m));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        personnelMovementService.delete(id);
        return ResponseEntity.ok().build();
    }
}
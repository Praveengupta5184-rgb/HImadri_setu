package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.service.PersonnelService;
import in.gov.moes.ncpor.polarops.service.PersonnelKitService;
import in.gov.moes.ncpor.polarops.dto.KitIssueRequest;
import in.gov.moes.ncpor.polarops.model.PersonnelKit;
import in.gov.moes.ncpor.polarops.service.ValidationService;
import in.gov.moes.ncpor.polarops.service.ValidationService.ValidationResult;
import org.springframework.security.core.Authentication;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/personnel")
@RequiredArgsConstructor
public class PersonnelController {
    private final PersonnelService personnelService;
    private final PersonnelKitService personnelKitService;
    private final ValidationService validationService;

    @GetMapping
    public ResponseEntity<List<Personnel>> getAll() {
        return ResponseEntity.ok(personnelService.getAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Personnel> getById(@PathVariable Long id) {
        Personnel p = personnelService.getById(id);
        return p != null ? ResponseEntity.ok(p) : ResponseEntity.notFound().build();
    }

    @PostMapping
    public ResponseEntity<Personnel> create(@RequestBody Personnel p) {
        return ResponseEntity.ok(personnelService.save(p));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Personnel> update(@PathVariable Long id, @RequestBody Personnel p) {
        if (personnelService.getById(id) == null) {
            return ResponseEntity.notFound().build();
        }
        p.setId(id);
        return ResponseEntity.ok(personnelService.save(p));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        personnelService.delete(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}/kit")
    public ResponseEntity<List<PersonnelKit>> kit(@PathVariable Long id) {
        ValidationResult validation = validationService.validatePersonnelExists(id);
        if (!validation.valid()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(personnelKitService.getForPersonnel(id));
    }

    @PostMapping("/{id}/kit")
    public ResponseEntity<?> issueKit(@PathVariable Long id, @RequestBody KitIssueRequest request, Authentication authentication) {
        ValidationResult validation = validationService.validatePersonnelExists(id);
        if (!validation.valid()) {
            return ResponseEntity.status(404)
                    .body(Map.of("error", validation.errorCode(), "message", validation.message()));
        }
        try {
            return ResponseEntity.status(201).body(personnelKitService.issue(id, request, authentication.getName()));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(409).body(Map.of("message", e.getMessage()));
        }
    }
}
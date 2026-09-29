package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.model.Expedition;
import in.gov.moes.ncpor.polarops.repository.ExpeditionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/v1/expeditions")
@RequiredArgsConstructor
public class ExpeditionController {
    private final ExpeditionRepository expeditionRepository;
    @GetMapping
    public List<Expedition> getExpeditions() { return expeditionRepository.findAll(); }
    @GetMapping("/{id}")
    public ResponseEntity<Expedition> getExpedition(@PathVariable Long id) { return expeditionRepository.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build()); }
    @PostMapping
    public ResponseEntity<Expedition> create(@RequestBody Expedition expedition) { return ResponseEntity.status(201).body(expeditionRepository.save(expedition)); }
    @PutMapping("/{id}")
    public ResponseEntity<Expedition> update(@PathVariable Long id, @RequestBody Expedition expedition) {
        if (!expeditionRepository.existsById(id)) return ResponseEntity.notFound().build();
        expedition.setId(id); return ResponseEntity.ok(expeditionRepository.save(expedition));
    }
}

package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.CargoDto;
import in.gov.moes.ncpor.polarops.dto.CargoMapper;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.service.CargoService;
import in.gov.moes.ncpor.polarops.service.RiskEngineService;
import in.gov.moes.ncpor.polarops.model.RiskEngineResult;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/cargo")
@RequiredArgsConstructor
@Tag(name = "Cargo Management", description = "APIs for managing polar expedition cargo")
@CrossOrigin(origins = "*")
public class CargoController {

    private final CargoService cargoService;
    private final CargoMapper cargoMapper;
    private final RiskEngineService riskEngineService;

    @GetMapping
    @Operation(summary = "Get all cargo")
    public ResponseEntity<List<CargoDto>> getAllCargo() {
        return ResponseEntity.ok(cargoMapper.toDtoList(cargoService.getAll()));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get cargo by ID")
    public ResponseEntity<CargoDto> getCargoById(@PathVariable Long id) {
        CargoPackage cargo = cargoService.getById(id);
        return cargo != null ? ResponseEntity.ok(cargoMapper.toDto(cargo)) : ResponseEntity.notFound().build();
    }

    @PostMapping
    @Operation(summary = "Create new cargo entry")
    public ResponseEntity<CargoDto> createCargo(@RequestBody CargoDto cargoDto) {
        CargoPackage savedCargo = cargoService.create(cargoMapper.toEntity(cargoDto));
        return ResponseEntity.status(HttpStatus.CREATED).body(cargoMapper.toDto(savedCargo));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update existing cargo")
    public ResponseEntity<CargoDto> updateCargo(@PathVariable Long id, @RequestBody CargoDto cargoDto) {
        CargoPackage updated = cargoService.update(id, cargoMapper.toEntity(cargoDto));
        return updated != null ? ResponseEntity.ok(cargoMapper.toDto(updated)) : ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete cargo")
    public ResponseEntity<Void> deleteCargo(@PathVariable Long id) {
        return cargoService.delete(id) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
    }

    @GetMapping("/{id}/risk-profile")
    @Operation(summary = "Evaluate and explain cargo risk")
    public ResponseEntity<RiskEngineResult> getCargoRiskProfile(
            @PathVariable Long id, 
            @RequestParam(defaultValue = "false") boolean damageDetected,
            @RequestParam(required = false) String destinationStation) {
        CargoPackage cargo = cargoService.getById(id);
        if (cargo == null) return ResponseEntity.notFound().build();

        RiskEngineResult result = riskEngineService.evaluateCargoRisk(cargo, damageDetected, destinationStation);
        return ResponseEntity.ok(result);
    }
    
    @PostMapping("/{id}/status")
    @Operation(summary = "Update cargo status")
    public ResponseEntity<CargoDto> updateStatus(
            @PathVariable Long id, 
            @RequestParam String status, 
            @RequestParam String performedBy, 
            @RequestParam(required = false) String location, 
            @RequestParam(required = false) String remarks) {
        
        in.gov.moes.ncpor.polarops.model.cargo.CargoStatus newStatus;
        try {
            newStatus = in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.valueOf(status.toUpperCase());
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
        
        CargoPackage updated = cargoService.updateStatus(id, newStatus, performedBy, location, remarks);
        return updated != null ? ResponseEntity.ok(cargoMapper.toDto(updated)) : ResponseEntity.notFound().build();
    }
    
    @GetMapping("/{id}/tracking")
    @Operation(summary = "Get cargo tracking history")
    public ResponseEntity<List<in.gov.moes.ncpor.polarops.dto.CargoTrackingEventDto>> getTrackingHistory(@PathVariable Long id) {
        return ResponseEntity.ok(cargoMapper.toTrackingDtoList(cargoService.getTrackingHistory(id)));
    }
    
    @PostMapping("/{id}/exception")
    @Operation(summary = "Report cargo exception")
    public ResponseEntity<CargoDto> reportException(
            @PathVariable Long id, 
            @RequestParam String type, // DELAYED, DAMAGED, LOST, CANCELLED
            @RequestParam String performedBy, 
            @RequestParam(required = false) String location, 
            @RequestParam String remarks) {
        
        in.gov.moes.ncpor.polarops.model.cargo.CargoStatus newStatus;
        try {
            newStatus = in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.valueOf(type.toUpperCase());
            if (!List.of(
                in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.DELAYED, 
                in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.DAMAGED, 
                in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.LOST, 
                in.gov.moes.ncpor.polarops.model.cargo.CargoStatus.CANCELLED).contains(newStatus)) {
                return ResponseEntity.badRequest().build();
            }
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
        
        CargoPackage updated = cargoService.updateStatus(id, newStatus, performedBy, location, remarks);
        return updated != null ? ResponseEntity.ok(cargoMapper.toDto(updated)) : ResponseEntity.notFound().build();
    }

    @PostMapping("/{id}/scan")
    @Operation(summary = "Record cargo scan location")
    public ResponseEntity<CargoDto> scanCargo(
            @PathVariable Long id, 
            @RequestBody in.gov.moes.ncpor.polarops.dto.CargoScanRequest request,
            @RequestHeader(value = "Authorization", required = false) String token) {
        
        // Normally extract user from token. Using a placeholder for this demo implementation if missing.
        String performedBy = "ScannedUser";
        
        CargoPackage updated = cargoService.recordScan(id, request.getLatitude(), request.getLongitude(), request.getSource(), request.getRemarks(), performedBy);
        return updated != null ? ResponseEntity.ok(cargoMapper.toDto(updated)) : ResponseEntity.notFound().build();
    }
}

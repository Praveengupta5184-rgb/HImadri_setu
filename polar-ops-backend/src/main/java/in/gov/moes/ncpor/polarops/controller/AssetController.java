package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.AssetDto;
import in.gov.moes.ncpor.polarops.dto.AssetMapper;
import in.gov.moes.ncpor.polarops.model.Asset;
import in.gov.moes.ncpor.polarops.service.AssetService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/assets")
@RequiredArgsConstructor
@Tag(name = "Asset Management", description = "APIs for managing polar expedition assets")
@CrossOrigin(origins = "*")
public class AssetController {

    private final AssetService assetService;
    private final AssetMapper assetMapper;

    @GetMapping
    @Operation(summary = "Get all assets")
    public ResponseEntity<List<AssetDto>> getAllAssets() {
        return ResponseEntity.ok(assetService.getAll());
    }

    @GetMapping("/available")
    @Operation(summary = "Get available assets")
    public ResponseEntity<List<AssetDto>> getAvailableAssets() {
        return ResponseEntity.ok(assetService.getAvailable());
    }

    @GetMapping("/assigned")
    @Operation(summary = "Get assigned assets")
    public ResponseEntity<List<AssetDto>> getAssignedAssets() {
        return ResponseEntity.ok(assetService.getAssigned());
    }

    @GetMapping("/category/{category}")
    @Operation(summary = "Get assets by category")
    public ResponseEntity<List<AssetDto>> getAssetsByCategory(@PathVariable String category) {
        return ResponseEntity.ok(assetService.getByCategory(category));
    }

    @GetMapping("/status/{status}")
    @Operation(summary = "Get assets by status")
    public ResponseEntity<List<AssetDto>> getAssetsByStatus(@PathVariable String status) {
        return ResponseEntity.ok(assetService.getByStatus(status));
    }

    @GetMapping("/condition/{condition}")
    @Operation(summary = "Get assets by condition")
    public ResponseEntity<List<AssetDto>> getAssetsByCondition(@PathVariable String condition) {
        return ResponseEntity.ok(assetService.getByCondition(condition));
    }

    @GetMapping("/criticality/{criticality}")
    @Operation(summary = "Get assets by criticality")
    public ResponseEntity<List<AssetDto>> getAssetsByCriticality(@PathVariable String criticality) {
        return ResponseEntity.ok(assetService.getByCriticality(criticality));
    }

    @GetMapping("/mission/{missionId}")
    @Operation(summary = "Get assets by mission")
    public ResponseEntity<List<AssetDto>> getAssetsByMission(@PathVariable Long missionId) {
        return ResponseEntity.ok(assetService.getByMissionId(missionId));
    }

    @GetMapping("/station/{stationId}")
    @Operation(summary = "Get assets by station")
    public ResponseEntity<List<AssetDto>> getAssetsByStation(@PathVariable Long stationId) {
        return ResponseEntity.ok(assetService.getByStationId(stationId));
    }

    @GetMapping("/personnel/{personnelId}")
    @Operation(summary = "Get assets assigned to personnel")
    public ResponseEntity<List<AssetDto>> getAssetsByPersonnel(@PathVariable Long personnelId) {
        return ResponseEntity.ok(assetService.getByPersonnelId(personnelId));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get asset by ID")
    public ResponseEntity<AssetDto> getAssetById(@PathVariable Long id) {
        AssetDto asset = assetService.getById(id);
        return asset != null ? ResponseEntity.ok(asset) : ResponseEntity.notFound().build();
    }

    @PostMapping
    @Operation(summary = "Create new asset")
    public ResponseEntity<?> createAsset(@RequestBody AssetDto assetDto, Authentication authentication) {
        try {
            AssetDto created = assetService.create(assetDto, authentication.getName());
            return ResponseEntity.status(HttpStatus.CREATED).body(created);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("code", "INVALID_INPUT", "message", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "ASSET_CODE_ALREADY_EXISTS", "message", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update existing asset")
    public ResponseEntity<?> updateAsset(@PathVariable Long id, @RequestBody AssetDto assetDto, Authentication authentication) {
        try {
            AssetDto updated = assetService.update(id, assetDto, authentication.getName());
            return updated != null ? ResponseEntity.ok(updated) : ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("code", "INVALID_INPUT", "message", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "ASSET_CODE_ALREADY_EXISTS", "message", e.getMessage()));
        }
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Update asset status")
    public ResponseEntity<?> updateAssetStatus(@PathVariable Long id, @RequestBody Map<String, String> payload, Authentication authentication) {
        try {
            String status = payload.get("status");
            if (status == null || status.trim().isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("code", "INVALID_INPUT", "message", "Status is required"));
            }
            AssetDto updated = assetService.updateStatus(id, status, authentication.getName());
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("code", "INVALID_INPUT", "message", e.getMessage()));
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "INVALID_STATE", "message", e.getMessage()));
        }
    }

    @PostMapping("/{id}/assign")
    @Operation(summary = "Assign asset to personnel")
    public ResponseEntity<?> assignAsset(@PathVariable Long id, @RequestBody Map<String, Long> payload, Authentication authentication) {
        try {
            Long personnelId = payload.get("personnelId");
            if (personnelId == null) {
                return ResponseEntity.badRequest().body(Map.of("code", "INVALID_INPUT", "message", "Personnel ID is required"));
            }
            AssetDto updated = assetService.assign(id, personnelId, authentication.getName());
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            String msg = e.getMessage();
            if (msg != null && (msg.contains("not found") || msg.contains("Not found"))) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("code", msg.contains("User") ? "USER_NOT_FOUND" : "PERSONNEL_NOT_FOUND", "message", msg));
            }
            return ResponseEntity.badRequest().body(Map.of("code", "INVALID_INPUT", "message", msg));
        } catch (IllegalStateException e) {
            String msg = e.getMessage();
            if (msg != null && msg.contains("already assigned")) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "ASSET_ALREADY_ASSIGNED", "message", msg));
            }
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "INVALID_STATE", "message", msg));
        }
    }

    @PostMapping("/{id}/unassign")
    @Operation(summary = "Unassign asset from personnel")
    public ResponseEntity<?> unassignAsset(@PathVariable Long id, Authentication authentication) {
        try {
            AssetDto updated = assetService.unassign(id, authentication.getName());
            return ResponseEntity.ok(updated);
        } catch (IllegalArgumentException e) {
            String msg = e.getMessage();
            if (msg != null && (msg.contains("not found") || msg.contains("Not found"))) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Map.of("code", "ASSET_NOT_FOUND", "message", msg));
            }
            return ResponseEntity.badRequest().body(Map.of("code", "INVALID_INPUT", "message", msg));
        } catch (IllegalStateException e) {
            String msg = e.getMessage();
            if (msg != null && msg.contains("not currently assigned")) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "ASSET_NOT_ASSIGNED", "message", msg));
            }
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "INVALID_STATE", "message", msg));
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete asset")
    public ResponseEntity<?> deleteAsset(@PathVariable Long id) {
        try {
            assetService.delete(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(Map.of("code", "INVALID_STATE", "message", e.getMessage()));
        }
    }
}
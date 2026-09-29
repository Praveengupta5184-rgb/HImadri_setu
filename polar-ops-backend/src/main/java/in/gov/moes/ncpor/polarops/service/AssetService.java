package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.dto.AssetDto;
import in.gov.moes.ncpor.polarops.dto.AssetMapper;
import in.gov.moes.ncpor.polarops.model.Asset;
import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.model.User;
import in.gov.moes.ncpor.polarops.model.Mission;
import in.gov.moes.ncpor.polarops.model.Station;
import in.gov.moes.ncpor.polarops.repository.AssetRepository;
import in.gov.moes.ncpor.polarops.repository.MissionRepository;
import in.gov.moes.ncpor.polarops.repository.PersonnelRepository;
import in.gov.moes.ncpor.polarops.repository.StationRepository;
import in.gov.moes.ncpor.polarops.repository.UserRepository;
import in.gov.moes.ncpor.polarops.service.ValidationService.ValidationResult;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AssetService {
    private final AssetRepository assetRepository;
    private final AssetMapper assetMapper;
    private final PersonnelRepository personnelRepository;
    private final UserRepository userRepository;
    private final MissionRepository missionRepository;
    private final StationRepository stationRepository;
    private final ValidationService validationService;
    private final AuditService auditService;

    private static final List<String> VALID_STATUSES = List.of(
            "AVAILABLE", "ASSIGNED", "IN_USE", "MAINTENANCE", "DAMAGED", "LOST", "RETIRED"
    );

    private static final List<String> VALID_CONDITIONS = List.of(
            "EXCELLENT", "GOOD", "FAIR", "POOR"
    );

    private static final List<String> VALID_CRITICALITIES = List.of(
            "LOW", "MEDIUM", "HIGH", "CRITICAL"
    );

    private static final List<String> ASSIGNED_STATUSES = List.of(
            "ASSIGNED", "IN_USE"
    );

    public List<AssetDto> getAll() {
        return assetMapper.toDtoList(assetRepository.findAll());
    }

    public AssetDto getById(Long id) {
        return assetRepository.findById(id)
                .map(assetMapper::toDto)
                .orElse(null);
    }

    public Optional<Asset> findById(Long id) {
        return assetRepository.findById(id);
    }

    @Transactional
    public AssetDto create(AssetDto dto, String operator) {
        validateCreate(dto);

        if (assetRepository.existsByAssetTag(dto.getAssetTag())) {
            throw new IllegalStateException("Asset code already exists");
        }

        Asset asset = assetMapper.toEntity(dto);
        enrichAsset(asset, dto);
        
        Asset saved = assetRepository.save(asset);
        auditService.logAction(operator, "ASSET_CREATED", saved.getAssetTag());
        
        return assetMapper.toDto(saved);
    }

    @Transactional
    public AssetDto update(Long id, AssetDto dto, String operator) {
        Asset existing = assetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Asset not found"));

        if (!existing.getAssetTag().equals(dto.getAssetTag()) && 
            assetRepository.existsByAssetTag(dto.getAssetTag())) {
            throw new IllegalStateException("Asset code already exists");
        }

        validateUpdate(dto, existing);

        // If status is changing to an assigned status, validate assignment
        String newStatus = dto.getStatus() != null ? dto.getStatus() : existing.getStatus();
        if (ASSIGNED_STATUSES.contains(newStatus) && !ASSIGNED_STATUSES.contains(existing.getStatus())) {
            validateAssignment(dto);
        }

        assetMapper.updateEntity(existing, dto);
        enrichAsset(existing, dto);
        
        Asset saved = assetRepository.save(existing);
        auditService.logAction(operator, "ASSET_UPDATED", saved.getAssetTag());
        
        return assetMapper.toDto(saved);
    }

    @Transactional
    public void delete(Long id) {
        Asset asset = assetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Asset not found"));
        
        if (ASSIGNED_STATUSES.contains(asset.getStatus())) {
            throw new IllegalStateException("Cannot delete asset that is assigned. Unassign first.");
        }
        
        assetRepository.deleteById(id);
    }

    @Transactional
    public AssetDto assign(Long assetId, Long personnelId, String operator) {
        Asset asset = assetRepository.findById(assetId)
                .orElseThrow(() -> new IllegalArgumentException("Asset not found"));

        if (ASSIGNED_STATUSES.contains(asset.getStatus()) && 
            (asset.getPersonnel() == null || !asset.getPersonnel().getId().equals(personnelId))) {
            throw new IllegalStateException("Asset is already assigned to another personnel");
        }

        Personnel personnel = personnelRepository.findById(personnelId)
                .orElseThrow(() -> new IllegalArgumentException("Personnel not found"));

        // Validate personnel-user linkage
        ValidationResult personnelValidation = validationService.validatePersonnelExists(personnelId);
        if (!personnelValidation.valid()) {
            throw new IllegalArgumentException("Personnel not found");
        }

        // Check if personnel has a linked user and if user is active
        if (personnel.getUser() != null) {
            ValidationResult userValidation = validationService.validateUserActive(personnel.getUser().getId());
            if (!userValidation.valid()) {
                throw new IllegalStateException("Associated user account is not active: " + userValidation.message());
            }
        }

        asset.setPersonnel(personnel);
        asset.setUser(personnel.getUser());
        asset.setStatus("ASSIGNED");
        
        Asset saved = assetRepository.save(asset);
        auditService.logAction(operator, "ASSET_ASSIGNED", 
                asset.getAssetTag() + " to " + personnel.getName());
        
        return assetMapper.toDto(saved);
    }

    @Transactional
    public AssetDto unassign(Long assetId, String operator) {
        Asset asset = assetRepository.findById(assetId)
                .orElseThrow(() -> new IllegalArgumentException("Asset not found"));

        if (!ASSIGNED_STATUSES.contains(asset.getStatus())) {
            throw new IllegalStateException("Asset is not currently assigned");
        }

        String assignedTo = asset.getPersonnel() != null ? asset.getPersonnel().getName() : "Unknown";
        
        asset.setPersonnel(null);
        asset.setUser(null);
        asset.setStatus("AVAILABLE");
        
        Asset saved = assetRepository.save(asset);
        auditService.logAction(operator, "ASSET_UNASSIGNED", 
                asset.getAssetTag() + " from " + assignedTo);
        
        return assetMapper.toDto(saved);
    }

    @Transactional
    public AssetDto updateStatus(Long id, String status, String operator) {
        Asset asset = assetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Asset not found"));

        if (!VALID_STATUSES.contains(status)) {
            throw new IllegalArgumentException("Invalid status: " + status + 
                    ". Valid statuses: " + String.join(", ", VALID_STATUSES));
        }

        // Validate status transitions
        if (ASSIGNED_STATUSES.contains(status) && 
            !ASSIGNED_STATUSES.contains(asset.getStatus())) {
            // Status changing to assigned - need personnel
            if (asset.getPersonnel() == null && asset.getUser() == null) {
                throw new IllegalStateException("Cannot set status to ASSIGNED/IN_USE without assigned personnel");
            }
        }

        String oldStatus = asset.getStatus();
        asset.setStatus(status);
        
        Asset saved = assetRepository.save(asset);
        auditService.logAction(operator, "ASSET_STATUS_CHANGED", 
                asset.getAssetTag() + ": " + oldStatus + " -> " + status);
        
        return assetMapper.toDto(saved);
    }

    public List<AssetDto> getByMissionId(Long missionId) {
        return assetMapper.toDtoList(assetRepository.findByMissionId(missionId));
    }

    public List<AssetDto> getByStationId(Long stationId) {
        return assetMapper.toDtoList(assetRepository.findByStationId(stationId));
    }

    public List<AssetDto> getByPersonnelId(Long personnelId) {
        return assetMapper.toDtoList(assetRepository.findByPersonnelId(personnelId));
    }

    public List<AssetDto> getByUserId(Long userId) {
        return assetMapper.toDtoList(assetRepository.findByUserId(userId));
    }

    public List<AssetDto> getByCategory(String category) {
        return assetMapper.toDtoList(assetRepository.findByCategory(category));
    }

    public List<AssetDto> getByStatus(String status) {
        return assetMapper.toDtoList(assetRepository.findByStatus(status));
    }

    public List<AssetDto> getByCondition(String condition) {
        return assetMapper.toDtoList(assetRepository.findByCondition(condition));
    }

    public List<AssetDto> getByCriticality(String criticality) {
        return assetMapper.toDtoList(assetRepository.findByCriticality(criticality));
    }

    public List<AssetDto> getAvailable() {
        return assetMapper.toDtoList(assetRepository.findByStatus("AVAILABLE"));
    }

    public List<AssetDto> getAssigned() {
        return assetMapper.toDtoList(assetRepository.findAll().stream()
                .filter(a -> ASSIGNED_STATUSES.contains(a.getStatus()))
                .toList());
    }

    private void validateCreate(AssetDto dto) {
        if (dto.getAssetTag() == null || dto.getAssetTag().trim().isEmpty()) {
            throw new IllegalArgumentException("Asset code is required");
        }
        if (dto.getName() == null || dto.getName().trim().isEmpty()) {
            throw new IllegalArgumentException("Asset name is required");
        }
        if (dto.getCategory() == null || dto.getCategory().trim().isEmpty()) {
            throw new IllegalArgumentException("Asset category is required");
        }
        if (dto.getStatus() != null && !VALID_STATUSES.contains(dto.getStatus())) {
            throw new IllegalArgumentException("Invalid status: " + dto.getStatus());
        }
        if (dto.getCondition() != null && !VALID_CONDITIONS.contains(dto.getCondition())) {
            throw new IllegalArgumentException("Invalid condition: " + dto.getCondition());
        }
        if (dto.getCriticality() != null && !VALID_CRITICALITIES.contains(dto.getCriticality())) {
            throw new IllegalArgumentException("Invalid criticality: " + dto.getCriticality());
        }
    }

    private void validateUpdate(AssetDto dto, Asset existing) {
        if (dto.getStatus() != null && !VALID_STATUSES.contains(dto.getStatus())) {
            throw new IllegalArgumentException("Invalid status: " + dto.getStatus());
        }
        if (dto.getCondition() != null && !VALID_CONDITIONS.contains(dto.getCondition())) {
            throw new IllegalArgumentException("Invalid condition: " + dto.getCondition());
        }
        if (dto.getCriticality() != null && !VALID_CRITICALITIES.contains(dto.getCriticality())) {
            throw new IllegalArgumentException("Invalid criticality: " + dto.getCriticality());
        }
    }

    private void validateAssignment(AssetDto dto) {
        if (dto.getPersonnelId() == null && dto.getUserId() == null) {
            throw new IllegalArgumentException("Personnel or User must be specified for assignment");
        }

        if (dto.getPersonnelId() != null) {
            Personnel personnel = personnelRepository.findById(dto.getPersonnelId())
                    .orElseThrow(() -> new IllegalArgumentException("Personnel not found"));
            
            if (personnel.getUser() != null) {
                ValidationResult userValidation = validationService.validateUserActive(personnel.getUser().getId());
                if (!userValidation.valid()) {
                    throw new IllegalStateException("Associated user account is not active: " + userValidation.message());
                }
            }
        }
    }

    private void enrichAsset(Asset asset, AssetDto dto) {
        if (dto.getMissionId() != null) {
            Mission mission = missionRepository.findById(dto.getMissionId())
                    .orElseThrow(() -> new IllegalArgumentException("Mission not found"));
            asset.setMission(mission);
        } else {
            asset.setMission(null);
        }

        if (dto.getStationId() != null) {
            Station station = stationRepository.findById(dto.getStationId())
                    .orElseThrow(() -> new IllegalArgumentException("Station not found"));
            asset.setStation(station);
        } else {
            asset.setStation(null);
        }

        if (dto.getPersonnelId() != null) {
            Personnel personnel = personnelRepository.findById(dto.getPersonnelId())
                    .orElseThrow(() -> new IllegalArgumentException("Personnel not found"));
            asset.setPersonnel(personnel);
            asset.setUser(personnel.getUser());
        } else if (dto.getUserId() != null) {
            User user = userRepository.findById(dto.getUserId())
                    .orElseThrow(() -> new IllegalArgumentException("User not found"));
            asset.setUser(user);
            // Find personnel linked to this user
            if (user.getPersonnel() != null) {
                asset.setPersonnel(user.getPersonnel());
            }
        } else {
            asset.setPersonnel(null);
            asset.setUser(null);
        }
    }
}
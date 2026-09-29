package in.gov.moes.ncpor.polarops.dto;

import in.gov.moes.ncpor.polarops.model.Asset;
import org.springframework.stereotype.Component;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class AssetMapper {

    public AssetDto toDto(Asset asset) {
        if (asset == null) return null;

        AssetDto dto = new AssetDto();
        dto.setId(asset.getId());
        dto.setAssetTag(asset.getAssetTag());
        dto.setName(asset.getName());
        dto.setCategory(asset.getCategory());
        dto.setDescription(asset.getDescription());
        dto.setSerialNumber(asset.getSerialNumber());
        dto.setManufacturer(asset.getManufacturer());
        dto.setModel(asset.getModel());
        dto.setQuantity(asset.getQuantity());
        dto.setStatus(asset.getStatus());
        dto.setCondition(asset.getCondition());
        dto.setCriticality(asset.getCriticality());
        dto.setLocation(asset.getLocation());
        dto.setPurchaseDate(asset.getPurchaseDate());
        dto.setPurchaseCost(asset.getPurchaseCost());
        dto.setLastMaintenanceDate(asset.getLastMaintenanceDate());
        dto.setNextMaintenanceDate(asset.getNextMaintenanceDate());
        dto.setMissionId(asset.getMission() != null ? asset.getMission().getId() : null);
        dto.setStationId(asset.getStation() != null ? asset.getStation().getId() : null);
        dto.setPersonnelId(asset.getPersonnel() != null ? asset.getPersonnel().getId() : null);
        dto.setPersonnelName(asset.getPersonnel() != null ? asset.getPersonnel().getName() : null);
        dto.setUserId(asset.getUser() != null ? asset.getUser().getId() : null);
        dto.setCreatedAt(asset.getCreatedAt() != null ? asset.getCreatedAt().toString() : null);
        dto.setUpdatedAt(asset.getUpdatedAt() != null ? asset.getUpdatedAt().toString() : null);
        return dto;
    }

    public Asset toEntity(AssetDto dto) {
        if (dto == null) return null;

        Asset asset = new Asset();
        asset.setId(dto.getId());
        asset.setAssetTag(dto.getAssetTag());
        asset.setName(dto.getName());
        asset.setCategory(dto.getCategory());
        asset.setDescription(dto.getDescription());
        asset.setSerialNumber(dto.getSerialNumber());
        asset.setManufacturer(dto.getManufacturer());
        asset.setModel(dto.getModel());
        asset.setQuantity(dto.getQuantity() != null ? dto.getQuantity() : 1);
        asset.setStatus(dto.getStatus() != null ? dto.getStatus() : "AVAILABLE");
        asset.setCondition(dto.getCondition() != null ? dto.getCondition() : "GOOD");
        asset.setCriticality(dto.getCriticality() != null ? dto.getCriticality() : "MEDIUM");
        asset.setLocation(dto.getLocation());
        asset.setPurchaseDate(dto.getPurchaseDate());
        asset.setPurchaseCost(dto.getPurchaseCost());
        asset.setLastMaintenanceDate(dto.getLastMaintenanceDate());
        asset.setNextMaintenanceDate(dto.getNextMaintenanceDate());
        return asset;
    }

    public void updateEntity(Asset asset, AssetDto dto) {
        if (asset == null || dto == null) return;

        asset.setAssetTag(dto.getAssetTag());
        asset.setName(dto.getName());
        asset.setCategory(dto.getCategory());
        asset.setDescription(dto.getDescription());
        asset.setSerialNumber(dto.getSerialNumber());
        asset.setManufacturer(dto.getManufacturer());
        asset.setModel(dto.getModel());
        asset.setQuantity(dto.getQuantity() != null ? dto.getQuantity() : 1);
        asset.setStatus(dto.getStatus() != null ? dto.getStatus() : "AVAILABLE");
        asset.setCondition(dto.getCondition() != null ? dto.getCondition() : "GOOD");
        asset.setCriticality(dto.getCriticality() != null ? dto.getCriticality() : "MEDIUM");
        asset.setLocation(dto.getLocation());
        asset.setPurchaseDate(dto.getPurchaseDate());
        asset.setPurchaseCost(dto.getPurchaseCost());
        asset.setLastMaintenanceDate(dto.getLastMaintenanceDate());
        asset.setNextMaintenanceDate(dto.getNextMaintenanceDate());
    }

    public List<AssetDto> toDtoList(List<Asset> assets) {
        return assets.stream().map(this::toDto).collect(Collectors.toList());
    }
}
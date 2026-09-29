package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.Asset;
import in.gov.moes.ncpor.polarops.model.Personnel;
import in.gov.moes.ncpor.polarops.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface AssetRepository extends JpaRepository<Asset, Long> {
    long countByStatus(String status);
    List<Asset> findByLocation(String location);
    List<Asset> findByMissionId(Long missionId);
    List<Asset> findByStationId(Long stationId);
    List<Asset> findByPersonnelId(Long personnelId);
    List<Asset> findByUserId(Long userId);
    List<Asset> findByAssetTag(String assetTag);
    Optional<Asset> findByAssetTagIgnoreCase(String assetTag);
    List<Asset> findByCategory(String category);
    List<Asset> findByStatus(String status);
    List<Asset> findByCondition(String condition);
    List<Asset> findByCriticality(String criticality);
    boolean existsByAssetTag(String assetTag);
}
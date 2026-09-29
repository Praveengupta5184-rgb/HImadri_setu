package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.StationArea;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StationAreaRepository extends JpaRepository<StationArea, Long> {
    List<StationArea> findByStationName(String stationName);
}

package in.gov.moes.ncpor.polarops.repository;

import in.gov.moes.ncpor.polarops.model.WeatherObservationHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface WeatherObservationHistoryRepository extends JpaRepository<WeatherObservationHistory, Long> {
    List<WeatherObservationHistory> findByStationOrderByObservedAtDesc(String station);
    List<WeatherObservationHistory> findByStationAndObservedAtBetween(String station, java.time.LocalDateTime start, java.time.LocalDateTime end);
}
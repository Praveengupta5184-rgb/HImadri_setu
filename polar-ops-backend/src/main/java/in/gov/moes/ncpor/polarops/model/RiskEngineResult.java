package in.gov.moes.ncpor.polarops.model;

import lombok.Data;
import lombok.Builder;
import java.time.LocalDateTime;
import java.util.Map;

@Data
@Builder
public class RiskEngineResult {
    private String modelVersion;
    private LocalDateTime timestamp;
    private int score;
    private String riskLevel;
    private Map<String, Integer> factorContribution;
    private WeatherObservation activeWeather;
}

package in.gov.moes.ncpor.polarops.model;

import lombok.Data;
import lombok.Builder;
import java.time.LocalDateTime;

@Data
@Builder
public class WeatherObservation {
    private String source;
    private String station;
    private LocalDateTime observationTime;
    private LocalDateTime retrievalTime;
    
    private Double temperature;
    private String temperatureUnit;
    
    private Double windSpeed;
    private String windSpeedUnit;
    
    private Double pressure;
    private String pressureUnit;
    
    private Double humidity;
    private String humidityUnit;
}

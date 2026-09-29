package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.WeatherObservation;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.HashMap;

@Service
public class WeatherService {
    private final RestTemplate restTemplate = new RestTemplate();
    
    // Hardcoded authoritative coordinates for actual Indian Polar Stations
    private static final Map<String, double[]> STATION_COORDS = new HashMap<>();
    static {
        STATION_COORDS.put("Maitri", new double[]{-70.7667, 11.7333});
        STATION_COORDS.put("Bharati", new double[]{-69.4083, 76.1950});
        STATION_COORDS.put("Himadri", new double[]{78.9167, 11.9167});
    }

    public WeatherObservation getLiveWeather(String stationName) {
        double[] coords = STATION_COORDS.get(stationName);
        if (coords == null) {
            return null; // unsupported station
        }

        String url = String.format("https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,wind_speed_10m,surface_pressure,relative_humidity_2m", coords[0], coords[1]);
        
        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(url, Map.class);
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> current = (Map<String, Object>) response.getBody().get("current");
                Map<String, Object> units = (Map<String, Object>) response.getBody().get("current_units");
                
                return WeatherObservation.builder()
                        .source("Open-Meteo API (Authoritative Proxy)")
                        .station(stationName)
                        .observationTime(LocalDateTime.parse((String) current.get("time")))
                        .retrievalTime(LocalDateTime.now())
                        .temperature(((Number) current.get("temperature_2m")).doubleValue())
                        .temperatureUnit((String) units.get("temperature_2m"))
                        .windSpeed(((Number) current.get("wind_speed_10m")).doubleValue())
                        .windSpeedUnit((String) units.get("wind_speed_10m"))
                        .pressure(((Number) current.get("surface_pressure")).doubleValue())
                        .pressureUnit((String) units.get("surface_pressure"))
                        .humidity(((Number) current.get("relative_humidity_2m")).doubleValue())
                        .humidityUnit((String) units.get("relative_humidity_2m"))
                        .build();
            }
        } catch (Exception e) {
            System.err.println("Failed to fetch weather for " + stationName + ": " + e.getMessage());
        }
        return null;
    }
}

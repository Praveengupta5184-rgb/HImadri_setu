package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
@Entity
@Table(name = "weather_observation_history")
public class WeatherObservationHistory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String station;
    private Double temperature;
    private Double windSpeed;
    private Double humidity;
    private Double pressure;
    private String condition;
    private LocalDateTime observedAt;
    private String source;
}
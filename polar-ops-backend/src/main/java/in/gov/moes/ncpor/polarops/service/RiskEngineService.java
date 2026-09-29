package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.model.RiskEngineResult;
import in.gov.moes.ncpor.polarops.model.WeatherObservation;
import in.gov.moes.ncpor.polarops.repository.CargoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class RiskEngineService {

    private final CargoRepository cargoRepository;
    private final WeatherService weatherService;

    public RiskEngineResult evaluateCargoRisk(CargoPackage cargoPackage, boolean damageDetected, String destinationStation) {
        int riskScore = 0;
        Map<String, Integer> factors = new HashMap<>();

        // 1. Packaging condition
        if (damageDetected) {
            riskScore += 40;
            factors.put("Packaging Damage", 40);
        }

        // 2. Deadline
        if (cargoPackage.getExpectedDeliveryDate() != null) {
            long daysUntilDelivery = ChronoUnit.DAYS.between(LocalDate.now(), cargoPackage.getExpectedDeliveryDate());
            if (daysUntilDelivery < 0) {
                riskScore += 30;
                factors.put("Overdue Delivery", 30);
            } else if (daysUntilDelivery < 7) {
                riskScore += 15;
                factors.put("Imminent Deadline", 15);
            }
        }

        // 3. Hazard
        if (Boolean.TRUE.equals(cargoPackage.getHazardousStatus())) {
            riskScore += 20;
            factors.put("Hazardous Material", 20);
        }

        // 4. Status
        if ("DELAYED".equalsIgnoreCase(cargoPackage.getCurrentStatus())) {
            riskScore += 25;
            factors.put("Delayed Status", 25);
        }

        // 5. Environmental Intelligence
        WeatherObservation weather = null;
        if (destinationStation != null) {
            weather = weatherService.getLiveWeather(destinationStation);
            if (weather != null) {
                if (weather.getWindSpeed() != null && weather.getWindSpeed() > 50.0) {
                    riskScore += 30;
                    factors.put("Severe Gale Wind Risk", 30);
                } else if (weather.getWindSpeed() != null && weather.getWindSpeed() > 30.0) {
                    riskScore += 15;
                    factors.put("High Wind Alert", 15);
                }
                
                if (weather.getTemperature() != null && weather.getTemperature() < -40.0) {
                    riskScore += 20;
                    factors.put("Extreme Cold Thermal Risk", 20);
                }
            }
        }

        // 6. Bounds check
        if (riskScore > 100) riskScore = 100;
        if (riskScore < 0) riskScore = 0;
        
        String riskLevel = "LOW";
        if (riskScore > 75) riskLevel = "CRITICAL";
        else if (riskScore > 40) riskLevel = "HIGH";
        else if (riskScore > 20) riskLevel = "MODERATE";

        cargoPackage.setRiskScore(riskScore);
        cargoRepository.save(cargoPackage);

        return RiskEngineResult.builder()
                .modelVersion("v1.2 (Environment-Aware)")
                .timestamp(LocalDateTime.now())
                .score(riskScore)
                .riskLevel(riskLevel)
                .factorContribution(factors)
                .activeWeather(weather)
                .build();
    }
}

package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.client.PredictiveLogisticsClient;
import in.gov.moes.ncpor.polarops.dto.CargoLogisticsResponse;
import in.gov.moes.ncpor.polarops.model.CargoInspection;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.repository.CargoRepository;
import in.gov.moes.ncpor.polarops.service.VisionService;
import in.gov.moes.ncpor.polarops.service.WeatherService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/cargo/intelligence")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CargoIntelligenceController {

    private final VisionService visionService;
    private final PredictiveLogisticsClient predictiveLogisticsClient;
    private final CargoRepository cargoRepository;
    private final WeatherService weatherService;

    @PostMapping("/inspect")
    public ResponseEntity<CargoInspection> inspectImage(@RequestParam("file") MultipartFile file) {
        try {
            CargoInspection inspection = visionService.inspectCargoImage(file);
            return ResponseEntity.ok(inspection);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/{cargoId}/predict-delay")
    public ResponseEntity<CargoLogisticsResponse> predictDelay(@PathVariable String cargoId) {
        Optional<CargoPackage> cargoOpt = cargoRepository.findByCargoId(cargoId);
        if (cargoOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        CargoPackage cargoPackage = cargoOpt.get();
        
        // Get weather risk for destination
        Double weatherRisk = 0.0;
        if (cargoPackage.getDestination() != null) {
            var weather = weatherService.getLiveWeather(cargoPackage.getDestination());
            if (weather != null && weather.getWindSpeed() != null) {
                weatherRisk = Math.min(1.0, weather.getWindSpeed() / 100.0);
            }
        }

        // Get historical delay rate - in real implementation this would come from CargoEvent history
        Double historicalDelayRate = 0.1;
        
        // Packaging condition from latest inspection
        Double packagingScore = 1.0;
        Boolean inspectionPassed = true;
        // In real implementation, query latest CargoInspection

        CargoLogisticsResponse response = predictiveLogisticsClient.predictCargoDelay(
                cargoPackage, weatherRisk, historicalDelayRate, packagingScore, inspectionPassed);
        
        return ResponseEntity.ok(response);
    }
}
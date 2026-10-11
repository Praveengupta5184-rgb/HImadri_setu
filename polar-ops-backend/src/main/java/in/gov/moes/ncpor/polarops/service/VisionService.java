package in.gov.moes.ncpor.polarops.service;

import com.google.zxing.BinaryBitmap;
import com.google.zxing.LuminanceSource;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.Result;
import com.google.zxing.client.j2se.BufferedImageLuminanceSource;
import com.google.zxing.common.HybridBinarizer;
import in.gov.moes.ncpor.polarops.model.CargoInspection;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.repository.CargoInspectionRepository;
import in.gov.moes.ncpor.polarops.repository.CargoRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class VisionService {

    private final CargoRepository cargoRepository;
    private final CargoInspectionRepository cargoInspectionRepository;
    private final RiskEngineService riskEngineService;
    private final in.gov.moes.ncpor.polarops.client.DamageDetectionClient damageDetectionClient;

    @Value("${file.upload-dir:/app/uploads}")
    private String uploadDir;

    public CargoInspection inspectCargoImage(MultipartFile file) throws IOException {
        // 1. Save image locally
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }
        
        String filename = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
        Path filePath = uploadPath.resolve(filename);
        file.transferTo(filePath.toFile());
        
        String imageUrl = "/uploads/" + filename;

        // 2. Decode QR/Barcode
        String cargoIdStr = null;
        try {
            BufferedImage bufferedImage = ImageIO.read(filePath.toFile());
            if (bufferedImage != null) {
                LuminanceSource source = new BufferedImageLuminanceSource(bufferedImage);
                BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
                Result result = new MultiFormatReader().decode(bitmap);
                cargoIdStr = result.getText();
                log.info("Detected QR/Barcode: {}", cargoIdStr);
            }
        } catch (Exception e) {
            log.warn("No QR/Barcode detected in image: {}", e.getMessage());
        }

        // Find cargo package
        CargoPackage cargoPackage = null;
        if (cargoIdStr != null) {
            // Check if cargoIdStr maps to an existing CargoPackage
            Optional<CargoPackage> optionalCargo = cargoRepository.findByCargoId(cargoIdStr);
            if (optionalCargo.isPresent()) {
                cargoPackage = optionalCargo.get();
            }
        }

        // 3. Computer Vision Damage Detection
        in.gov.moes.ncpor.polarops.dto.DamageDetectionResponse damageResponse = damageDetectionClient.detectDamage(imageUrl);
        Boolean damageDetected = null;
        String notes = "Image parsed for Cargo ID.";
        String damageDetectionModel = null;
        String damageType = null;
        String recommendation = null;
        Double damageConfidence = 1.0;

        if (damageResponse != null) {
            damageDetected = damageResponse.getIsDamaged();
            damageType = damageResponse.getDamageType();
            recommendation = damageResponse.getRecommendation();
            damageConfidence = damageResponse.getConfidence();
            damageDetectionModel = damageResponse.getAiMode();
            if (Boolean.TRUE.equals(damageDetected)) {
                notes += " Damage detected: " + damageType;
            } else {
                notes += " No damage detected.";
            }
        } else {
            notes += " Damage detection unavailable.";
        }
        
        // 4. Update Risk if applicable
        if (cargoPackage != null && Boolean.TRUE.equals(damageDetected)) {
            riskEngineService.evaluateCargoRisk(cargoPackage, damageDetected, cargoPackage.getDestination());
        }

        // 5. Store Inspection Audit
        CargoInspection inspection = CargoInspection.builder()
                .cargoPackage(cargoPackage)
                .inspectorName("AUTO-CV-SYSTEM")
                .notes(notes)
                .passed(!Boolean.TRUE.equals(damageDetected))
                .inspectionDate(LocalDateTime.now())
                .imageUrl(imageUrl)
                .barcodeModel("ZXING_BARCODE_SCANNER")
                .damageDetectionModel(damageDetectionModel)
                .modelVersion("3.5.3")
                .confidence(damageConfidence)
                .detectedObjects("[]")
                .damageDetected(damageDetected)
                .damageType(damageType)
                .recommendation(recommendation)
                .build();

        return cargoInspectionRepository.save(inspection);
    }
}

package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.model.CargoInspection;
import in.gov.moes.ncpor.polarops.service.VisionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@RestController
@RequestMapping("/api/v1/cargo/intelligence")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CargoIntelligenceController {

    private final VisionService visionService;

    @PostMapping("/inspect")
    public ResponseEntity<CargoInspection> inspectImage(@RequestParam("file") MultipartFile file) {
        try {
            CargoInspection inspection = visionService.inspectCargoImage(file);
            return ResponseEntity.ok(inspection);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}

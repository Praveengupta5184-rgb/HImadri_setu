package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.model.Station;
import in.gov.moes.ncpor.polarops.service.StationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import lombok.RequiredArgsConstructor;
import java.util.List;

@RestController
@RequestMapping("/api/v1/stations")
@RequiredArgsConstructor
public class StationController {
    private final StationService stationService;
    
    @GetMapping
    public List<Station> getStations() {
        return stationService.getAll();
    }
}

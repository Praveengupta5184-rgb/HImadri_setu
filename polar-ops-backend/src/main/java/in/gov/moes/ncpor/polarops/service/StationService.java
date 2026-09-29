package in.gov.moes.ncpor.polarops.service;

import in.gov.moes.ncpor.polarops.model.Station;
import in.gov.moes.ncpor.polarops.repository.StationRepository;
import org.springframework.stereotype.Service;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import java.util.List;

@Service
@RequiredArgsConstructor
public class StationService {
    private final StationRepository stationRepository;

    @PostConstruct
    public void initStations() {
        if (stationRepository.count() == 0) {
            stationRepository.save(Station.builder()
                .name("Maitri")
                .location("Schirmacher Oasis, Antarctica")
                .latitude(-70.7661)
                .longitude(11.7322)
                .coordinatesSource("ncpor.res.in")
                .type("RESEARCH")
                .status("OPERATIONAL")
                .currentCapacity(25)
                .maxCapacity(65)
                .build());

            stationRepository.save(Station.builder()
                .name("Bharati")
                .location("Larsemann Hills, Antarctica")
                .latitude(-69.4078)
                .longitude(76.1872)
                .coordinatesSource("ncpor.res.in")
                .type("RESEARCH")
                .status("OPERATIONAL")
                .currentCapacity(47)
                .maxCapacity(72)
                .build());

            stationRepository.save(Station.builder()
                .name("Himadri")
                .location("Svalbard, Arctic")
                .latitude(78.9167)
                .longitude(11.9333)
                .coordinatesSource("wikipedia.org / ncpor.res.in")
                .type("RESEARCH")
                .status("OPERATIONAL")
                .currentCapacity(5)
                .maxCapacity(8)
                .build());

            stationRepository.save(Station.builder()
                .name("Himansh")
                .location("Spiti, Himalayas")
                .latitude(32.4000)
                .longitude(77.5800)
                .coordinatesSource("ncpor.res.in (Approximate)")
                .type("RESEARCH")
                .status("OPERATIONAL")
                .currentCapacity(2)
                .maxCapacity(4)
                .build());
        }
    }

    public List<Station> getAll() {
        return stationRepository.findAll();
    }
}

package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.dto.RiskScoreResponse;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
@Service
public class RiskScoreService {
    public RiskScoreResponse calculateRisk(CargoPackage cargo) {
        int riskScore = 0;
        long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), cargo.getExpectedDeliveryDate());
        if (daysRemaining < 5) riskScore += 30;
        else if (daysRemaining < 10) riskScore += 20;
        else if (daysRemaining < 15) riskScore += 10;
        
        if (cargo.getHazardousStatus()) riskScore += 25;
        riskScore += 15; // default packaging quality risk
        riskScore += 10; // default weather risk
        riskScore += 8;  // default historical delay risk
        
        String riskLevel = riskScore >= 75 ? "CRITICAL" : riskScore >= 50 ? "HIGH" : riskScore >= 25 ? "MEDIUM" : "LOW";
        List<String> recommendations = new ArrayList<>();
        if (daysRemaining < 10) recommendations.add("Expedite shipment");
        if (cargo.getHazardousStatus()) recommendations.add("Verify hazardous material documentation");
        if (riskScore >= 50) recommendations.add("Contact logistics provider");
        
        return RiskScoreResponse.builder().cargoId(cargo.getCargoId()).riskScore(riskScore).riskLevel(riskLevel).recommendations(recommendations).build();
    }
}

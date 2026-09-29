package in.gov.moes.ncpor.polarops.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DashboardData {
    private MissionReadiness missionReadiness;
    private long activeExpeditions;
    private long cargoInTransit;
    private long inventoryCriticalItems;
    private long personnelDeployed;
    private long criticalAssets;
    private long activeEmergencies;
}

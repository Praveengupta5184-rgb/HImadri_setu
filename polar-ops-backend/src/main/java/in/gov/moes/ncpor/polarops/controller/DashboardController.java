package in.gov.moes.ncpor.polarops.controller;

import in.gov.moes.ncpor.polarops.dto.DashboardData;
import in.gov.moes.ncpor.polarops.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
public class DashboardController {
    
    private final DashboardService dashboardService;

    @GetMapping
    public DashboardData getDashboard() {
        return dashboardService.getDashboardData();
    }
}

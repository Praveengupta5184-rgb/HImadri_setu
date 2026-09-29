import os

base_dir = "src/main/java/in/gov/moes/ncpor/polarops"
dirs = ["model", "dto", "service", "controller", "security", "exception", "config"]

for d in dirs:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

def write_file(path, content):
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

# 1. Models
write_file(f"{base_dir}/model/Role.java", """package in.gov.moes.ncpor.polarops.model;
public enum Role {
    SUPER_ADMIN, EXPEDITION_MANAGER, STATION_COMMANDER, LOGISTICS_OFFICER, 
    MEDICAL_OFFICER, SCIENTIST, ENGINEER, INVENTORY_MANAGER, SECURITY_OFFICER, EMERGENCY_RESPONDER
}
""")

write_file(f"{base_dir}/model/User.java", """package in.gov.moes.ncpor.polarops.model;
import lombok.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class User {
    private Long id;
    private String email;
    private String password;
    private Role role;
    private String name;
}
""")

write_file(f"{base_dir}/model/CargoPackage.java", """package in.gov.moes.ncpor.polarops.model;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class CargoPackage {
    private Long id;
    private String cargoId;
    private Long expeditionId;
    private String ownerOrganization;
    private String projectName;
    private String destination;
    private Integer packageNumber;
    private Integer totalPackages;
    private Double weight;
    private String dimensions;
    private String category;
    private Boolean hazardousStatus;
    private String storageConditions;
    private String currentStatus;
    private LocalDate expectedDeliveryDate;
    private Integer riskScore;
    private LocalDateTime createdAt;
}
""")

write_file(f"{base_dir}/model/InventoryItem.java", """package in.gov.moes.ncpor.polarops.model;
import lombok.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class InventoryItem {
    private Long itemId;
    private String name;
    private String category;
    private Integer quantityAvailable;
    private Integer minimumStockLevel;
    private String unit;
    private String location;
    private String station;
}
""")

write_file(f"{base_dir}/model/AuditLog.java", """package in.gov.moes.ncpor.polarops.model;
import lombok.*;
import java.time.LocalDateTime;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AuditLog {
    private Long id;
    private String user;
    private String action;
    private String entity;
    private LocalDateTime timestamp;
}
""")

write_file(f"{base_dir}/model/EmergencyIncident.java", """package in.gov.moes.ncpor.polarops.model;
import lombok.*;
import java.time.LocalDateTime;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class EmergencyIncident {
    private Long incidentId;
    private String type;
    private String location;
    private String severity;
    private String status;
    private LocalDateTime reportedAt;
}
""")

# 2. DTOs
write_file(f"{base_dir}/dto/RiskScoreResponse.java", """package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
import java.util.List;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class RiskScoreResponse {
    private String cargoId;
    private int riskScore;
    private String riskLevel;
    private List<String> recommendations;
}
""")

write_file(f"{base_dir}/dto/ForecastResponse.java", """package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class ForecastResponse {
    private Long itemId;
    private String itemName;
    private Integer currentStock;
    private Integer predictedConsumption30Days;
    private Boolean shortageAlert;
    private Integer confidenceIntervalLower;
    private Integer confidenceIntervalUpper;
    private Integer recommendedProcurement;
    private String urgency;
}
""")

write_file(f"{base_dir}/dto/AuthRequest.java", """package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AuthRequest {
    private String email;
    private String password;
}
""")

write_file(f"{base_dir}/dto/AuthResponse.java", """package in.gov.moes.ncpor.polarops.dto;
import lombok.*;
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class AuthResponse {
    private String token;
    private String role;
}
""")

# 3. Services
write_file(f"{base_dir}/service/UserService.java", """package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.*;
import org.springframework.stereotype.Service;
import jakarta.annotation.PostConstruct;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
@Service
public class UserService {
    private final Map<Long, User> users = new ConcurrentHashMap<>();
    @PostConstruct
    public void initUsers() {
        users.put(1L, User.builder().id(1L).email("admin@polarops.gov.in").password("admin123").role(Role.SUPER_ADMIN).name("System Administrator").build());
        users.put(2L, User.builder().id(2L).email("expedition@polarops.gov.in").password("mgr123").role(Role.EXPEDITION_MANAGER).name("Expedition Manager").build());
        users.put(3L, User.builder().id(3L).email("medical@polarops.gov.in").password("med123").role(Role.MEDICAL_OFFICER).name("Medical Officer").build());
    }
    public Optional<User> findByEmail(String email) {
        return users.values().stream().filter(u -> u.getEmail().equals(email)).findFirst();
    }
}
""")

write_file(f"{base_dir}/service/CargoService.java", """package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import org.springframework.stereotype.Service;
import jakarta.annotation.PostConstruct;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
@Service
public class CargoService {
    private final Map<Long, CargoPackage> cargoStore = new ConcurrentHashMap<>();
    @PostConstruct
    public void init() {
        for(long i=1; i<=50; i++) {
            cargoStore.put(i, CargoPackage.builder()
                .id(i)
                .cargoId("CARGO-" + (1000 + i))
                .expeditionId(1L)
                .ownerOrganization("IIT Delhi")
                .projectName("Atmospheric Research")
                .destination(i % 2 == 0 ? "Maitri" : "Bharati")
                .packageNumber(1)
                .totalPackages(5)
                .weight(25.5 + i)
                .dimensions("50x40x30 cm")
                .category("SCIENTIFIC_EQUIPMENT")
                .hazardousStatus(i % 5 == 0)
                .storageConditions("Room temperature")
                .currentStatus("IN_TRANSIT")
                .expectedDeliveryDate(LocalDate.now().plusDays(15 - (i%10)))
                .riskScore((int)(30 + (i%50)))
                .createdAt(LocalDateTime.now())
                .build());
        }
    }
    public List<CargoPackage> getAll() { return new ArrayList<>(cargoStore.values()); }
    public CargoPackage getById(Long id) { return cargoStore.get(id); }
}
""")

write_file(f"{base_dir}/service/InventoryService.java", """package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import org.springframework.stereotype.Service;
import jakarta.annotation.PostConstruct;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
@Service
public class InventoryService {
    private final Map<Long, InventoryItem> inventoryStore = new ConcurrentHashMap<>();
    @PostConstruct
    public void init() {
        for(long i=1; i<=100; i++) {
            inventoryStore.put(i, InventoryItem.builder()
                .itemId(i)
                .name("Item " + i)
                .category(i % 3 == 0 ? "Food" : (i % 3 == 1 ? "Medical" : "Spare Parts"))
                .quantityAvailable((int)(50 + (i%50)))
                .minimumStockLevel(20)
                .unit("kg")
                .location("Store " + (i%5))
                .station(i % 2 == 0 ? "Maitri" : "Bharati")
                .build());
        }
    }
    public List<InventoryItem> getAll() { return new ArrayList<>(inventoryStore.values()); }
    public InventoryItem getById(Long id) { return inventoryStore.get(id); }
}
""")

write_file(f"{base_dir}/service/RiskScoreService.java", """package in.gov.moes.ncpor.polarops.service;
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
""")

write_file(f"{base_dir}/service/ForecastingService.java", """package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.dto.ForecastResponse;
import org.springframework.stereotype.Service;
@Service
public class ForecastingService {
    public ForecastResponse forecastInventory(InventoryItem item) {
        double avgDailyConsumption = 2.5; 
        int forecastDays = 30;
        double predictedConsumption = avgDailyConsumption * forecastDays;
        boolean shortageAlert = item.getQuantityAvailable() < predictedConsumption;
        int recommendedProcurement = (int) (predictedConsumption - item.getQuantityAvailable() + item.getMinimumStockLevel());
        
        return ForecastResponse.builder()
            .itemId(item.getItemId())
            .itemName(item.getName())
            .currentStock(item.getQuantityAvailable())
            .predictedConsumption30Days((int) predictedConsumption)
            .shortageAlert(shortageAlert)
            .confidenceIntervalLower((int) (predictedConsumption * 0.8))
            .confidenceIntervalUpper((int) (predictedConsumption * 1.2))
            .recommendedProcurement(Math.max(0, recommendedProcurement))
            .urgency(shortageAlert ? "HIGH" : "NORMAL")
            .build();
    }
}
""")

write_file(f"{base_dir}/service/AuditService.java", """package in.gov.moes.ncpor.polarops.service;
import in.gov.moes.ncpor.polarops.model.AuditLog;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
@Service
public class AuditService {
    private final List<AuditLog> logs = Collections.synchronizedList(new ArrayList<>());
    private long idCounter = 1;
    public void logAction(String user, String action, String entity) {
        logs.add(AuditLog.builder().id(idCounter++).user(user).action(action).entity(entity).timestamp(LocalDateTime.now()).build());
    }
    public List<AuditLog> getLogs() { return new ArrayList<>(logs); }
}
""")

# 4. Controllers
write_file(f"{base_dir}/controller/AuthController.java", """package in.gov.moes.ncpor.polarops.controller;
import in.gov.moes.ncpor.polarops.dto.*;
import in.gov.moes.ncpor.polarops.service.UserService;
import in.gov.moes.ncpor.polarops.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.Optional;
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    private final UserService userService;
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        Optional<User> userOpt = userService.findByEmail(request.getEmail());
        if(userOpt.isPresent() && userOpt.get().getPassword().equals(request.getPassword())) {
            // Dummy token generation for demo
            String token = "jwt-token-mock-" + userOpt.get().getId();
            return ResponseEntity.ok(AuthResponse.builder().token(token).role(userOpt.get().getRole().name()).build());
        }
        return ResponseEntity.status(401).build();
    }
}
""")

write_file(f"{base_dir}/controller/CargoV2Controller.java", """package in.gov.moes.ncpor.polarops.controller;
import in.gov.moes.ncpor.polarops.model.CargoPackage;
import in.gov.moes.ncpor.polarops.dto.RiskScoreResponse;
import in.gov.moes.ncpor.polarops.service.CargoService;
import in.gov.moes.ncpor.polarops.service.RiskScoreService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;
@RestController
@RequestMapping("/api/cargo")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CargoV2Controller {
    private final CargoService cargoService;
    private final RiskScoreService riskScoreService;
    @GetMapping
    public ResponseEntity<List<CargoPackage>> getAll() {
        return ResponseEntity.ok(cargoService.getAll());
    }
    @GetMapping("/{id}")
    public ResponseEntity<CargoPackage> getById(@PathVariable Long id) {
        CargoPackage pkg = cargoService.getById(id);
        return pkg != null ? ResponseEntity.ok(pkg) : ResponseEntity.notFound().build();
    }
    @GetMapping("/{id}/risk-score")
    public ResponseEntity<RiskScoreResponse> getRiskScore(@PathVariable Long id) {
        CargoPackage pkg = cargoService.getById(id);
        if(pkg != null) return ResponseEntity.ok(riskScoreService.calculateRisk(pkg));
        return ResponseEntity.notFound().build();
    }
}
""")

write_file(f"{base_dir}/controller/InventoryController.java", """package in.gov.moes.ncpor.polarops.controller;
import in.gov.moes.ncpor.polarops.model.InventoryItem;
import in.gov.moes.ncpor.polarops.dto.ForecastResponse;
import in.gov.moes.ncpor.polarops.service.InventoryService;
import in.gov.moes.ncpor.polarops.service.ForecastingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import lombok.RequiredArgsConstructor;
import java.util.List;
@RestController
@RequestMapping("/api/inventory")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class InventoryController {
    private final InventoryService inventoryService;
    private final ForecastingService forecastingService;
    @GetMapping
    public ResponseEntity<List<InventoryItem>> getAll() {
        return ResponseEntity.ok(inventoryService.getAll());
    }
    @GetMapping("/{id}")
    public ResponseEntity<InventoryItem> getById(@PathVariable Long id) {
        InventoryItem item = inventoryService.getById(id);
        return item != null ? ResponseEntity.ok(item) : ResponseEntity.notFound().build();
    }
    @PostMapping("/{id}/forecast")
    public ResponseEntity<ForecastResponse> getForecast(@PathVariable Long id) {
        InventoryItem item = inventoryService.getById(id);
        if(item != null) return ResponseEntity.ok(forecastingService.forecastInventory(item));
        return ResponseEntity.notFound().build();
    }
}
""")

write_file(f"{base_dir}/security/JwtUtil.java", """package in.gov.moes.ncpor.polarops.security;
// Placeholder for actual JWT filter logic
public class JwtUtil {
    public static final String SECRET = "mysecretkey";
}
""")

print("Successfully generated all files.")

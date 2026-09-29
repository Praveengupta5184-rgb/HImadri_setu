package in.gov.moes.ncpor.polarops.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "assets", uniqueConstraints = @UniqueConstraint(columnNames = "assetTag"))
public class Asset {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String assetTag;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String category;

    private String description;

    private String serialNumber;

    private String manufacturer;

    private String model;

    private Integer quantity;

    @Column(nullable = false)
    private String status; // AVAILABLE, ASSIGNED, IN_USE, MAINTENANCE, DAMAGED, LOST, RETIRED

    @Column(nullable = false)
    private String condition; // EXCELLENT, GOOD, FAIR, POOR

    private String criticality; // LOW, MEDIUM, HIGH, CRITICAL

    private String location;

    private LocalDate purchaseDate;

    private Double purchaseCost;

    private LocalDate lastMaintenanceDate;

    private LocalDate nextMaintenanceDate;

    @ManyToOne
    @JoinColumn(name = "mission_id")
    private Mission mission;

    @ManyToOne
    @JoinColumn(name = "station_id")
    private Station station;

    @ManyToOne
    @JoinColumn(name = "personnel_id")
    private Personnel personnel;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
        if (status == null) status = "AVAILABLE";
        if (condition == null) condition = "GOOD";
        if (criticality == null) criticality = "MEDIUM";
        if (quantity == null) quantity = 1;
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
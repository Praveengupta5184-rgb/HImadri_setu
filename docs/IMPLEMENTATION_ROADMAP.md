# POLAR-OPS Implementation Roadmap

This roadmap outlines the transformation of the POLAR-OPS prototype into a fully functional, real-data-oriented command platform.

## Phase 1: Database and Persistence Integration
**Objective:** Replace in-memory mock data (ConcurrentHashMap) with a real relational database to ensure data persistence and reliable operations.
**Files affected:** 
- `polar-ops-backend/pom.xml`
- `docker-compose.yml`
- `polar-ops-backend/src/main/resources/application.properties`
- All Model classes (to add JPA annotations)
- `CargoService`, `InventoryService`, `UserService`
**Backend changes:** Add Spring Data JPA and PostgreSQL driver dependencies. Replace `ConcurrentHashMap` with Spring Data Repositories.
**Frontend changes:** None.
**Database changes:** Add PostgreSQL container to docker-compose. Configure JPA entity mappings and generate schema.
**External data requirements:** None.
**Testing requirements:** Verify CRUD operations persist across container restarts.
**Risk of breaking existing functionality:** High. Migrating from mock data to JPA can introduce lazy-loading issues and transactional errors.

## Phase 2: Frontend-Backend API Integration
**Objective:** Connect the Flutter Web frontend to the real Spring Boot backend instead of relying on hardcoded UI states.
**Files affected:**
- `polar_ops_web/pubspec.yaml`
- `polar_ops_web/lib/screens/**`
- `polar_ops_web/lib/services/**`
**Backend changes:** Ensure CORS is correctly configured for the Flutter Web origin.
**Frontend changes:** Add `http` package. Create API client services (`CargoApiClient`, `InventoryApiClient`). Replace hardcoded `web_dashboard_screen.dart` variables and charts with future builders fetching real JSON payloads.
**Database changes:** None.
**External data requirements:** None.
**Testing requirements:** End-to-end integration tests confirming dashboard numbers match backend database records.
**Risk of breaking existing functionality:** Medium. Requires rewriting how state is managed in the frontend.

## Phase 3: Real Data Sources & External APIs
**Objective:** Implement live tracking and weather integration to replace simulated placeholder data.
**Files affected:**
- `polar-ops-backend/src/main/java/in/gov/moes/ncpor/polarops/service/WeatherService.java`
- `polar-ops-backend/src/main/java/in/gov/moes/ncpor/polarops/service/VesselTrackingService.java`
**Backend changes:** Build HTTP clients integrating with real-world public APIs (e.g., OpenWeatherMap, actual vessel AIS APIs).
**Frontend changes:** Bind map widgets and weather UI components to the new live data endpoints.
**Database changes:** Caching tables for external API responses to avoid rate limits.
**External data requirements:** Live weather data source, vessel AIS coordinates.
**Testing requirements:** Mocking external APIs during unit tests. Handling API downtime gracefully.
**Risk of breaking existing functionality:** Low. This is mostly additive.

## Phase 4: Authentic Digital Twin & Computer Vision
**Objective:** Replace the CSS/Transform isometric 3D simulation with a legitimate 3D renderer and integrate real computer vision pipelines.
**Files affected:**
- `polar_ops_web/pubspec.yaml`
- `polar_ops_web/lib/screens/twin/digital_twin_screen.dart`
- Python AI microservices.
**Backend changes:** Build endpoints to relay telemetry and room sensor data to the frontend in real-time (WebSockets).
**Frontend changes:** Implement WebGL/Three.js via Flutter web wrappers or use a proper 3D rendering engine to display actual CAD/floor plans of Maitri/Bharati.
**Database changes:** Store spatial coordinates, sensor IDs, and node mappings.
**External data requirements:** Actual 3D models (.obj/.gltf) of the stations.
**Testing requirements:** Performance profiling on the frontend to ensure 3D rendering runs at 60fps.
**Risk of breaking existing functionality:** High. Flutter Web performance with 3D can be challenging.

## Phase 5: Actual AI inference & Forecasting
**Objective:** Replace hardcoded arithmetic algorithms in `RiskScoreService` and `ForecastingService` with real AI models.
**Files affected:**
- `polar-ops-backend/src/main/java/in/gov/moes/ncpor/polarops/service/RiskScoreService.java`
- `docker-compose.yml`
**Backend changes:** Either call a dedicated Python microservice handling ML inference or load ONNX/TensorFlow models directly in Java.
**Frontend changes:** Reflect actual AI confidence intervals and insights.
**Database changes:** Store historical incident reports and consumption data required for AI training.
**External data requirements:** Historical logistics data from NCPOR.
**Testing requirements:** Validate model accuracy against a holdout test set.
**Risk of breaking existing functionality:** Low. Replaces the backend logic for specific endpoints.

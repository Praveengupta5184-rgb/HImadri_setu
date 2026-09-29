# POLAR-OPS Backend

## Setup:
1. Install Java 17
2. Run: `mvn spring-boot:run` or open in IDE
3. Open: http://localhost:8080/swagger-ui.html

## Mock Users:
- admin@polarops.gov.in / admin123 (Super Admin)
- expedition@polarops.gov.in / mgr123 (Expedition Manager)
- logistics@polarops.gov.in / log123 (Logistics Officer)

## API Endpoints:
- POST /api/auth/login
- GET /api/cargo
- GET /api/cargo/{id}/risk-score
- GET /api/inventory
- POST /api/inventory/{id}/forecast

## Documentation
- [Phase 17A API & Architecture](PHASE_17_DOCUMENTATION.md)
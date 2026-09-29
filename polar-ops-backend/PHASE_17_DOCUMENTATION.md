# PolarOps - Phase 17A Backend Architecture & API Documentation

## 1. Architecture Relationships

The core entity relationships introduced in Phase 17 form the backbone of field operations.
Relationships:
- **Expedition** ➔ **Mission** (1:N) - An expedition acts as a container for multiple operational missions.
- **Mission** ➔ **Mission Team** (1:N) - Each mission can have multiple teams (e.g. Field, Support).
- **Mission Team** ➔ **Mission Member** (1:N) - Personnel become members of specific teams during an active mission.
- **Mission Team** ➔ **Team Target** (1:N) - Quantitative goals assigned to a team.
- **Mission Team** / **Personnel** ➔ **Mission Assignment** (1:N) - Individual task assignments.
- **Mission Member** ➔ **Personnel Location** (1:N) - Geospatial tracking data for the member while active.

*Additional Relationships:*
- **Cargo / Inventory / Assets / Emergency**: Directly linked to either the Expedition or the Mission level based on the previous Phase implementations. These are aggregated in the Mission Dashboard for readiness evaluation.

## 2. API Endpoints

### MISSION
- **Create Mission**
  - `POST /api/v1/missions`
  - Purpose: Creates a new mission and auto-generates a `missionCode` (e.g. `POLAR-2026-001`).
  - Auth: Must have `OFFICER` roles (`ADMIN`, `MISSION_OFFICER`, `STATION_OFFICER`, `LOGISTICS_OFFICER`).
  - Validation: Requires an attached Expedition ID, `missionName`, and `objective`.
- **List Missions**
  - `GET /api/v1/missions`
  - Auth: Must have `OFFICER` role.
- **Get Mission**
  - `GET /api/v1/missions/{code}`
  - Auth: Any authenticated user with active membership or an `OFFICER` role.
- **Mission Closure**
  - `POST /api/v1/missions/{code}/close`
  - Purpose: Transition mission status to `CLOSED`.

### TEAM
- **Create Team**
  - `POST /api/v1/missions/{code}/teams`
  - Auth: Must have `OFFICER` role.
  - Validation: Mission must not be CLOSED. Requires `teamCode` and `teamName`.
- **List Teams**
  - `GET /api/v1/missions/{code}/teams`
  - Auth: Active members of the mission or Officers.

### MEMBERSHIP
- **Add Member**
  - `POST /api/v1/missions/{code}/teams/{teamId}/members/{personnelId}`
  - Auth: Must have `OFFICER` role.
  - Behavior: Personnel is marked as `ACTIVE` membership.
- **Remove Member**
  - `DELETE /api/v1/missions/{code}/members/{personnelId}`
  - Auth: Must have `OFFICER` role.
  - Behavior: Sets membership to `INACTIVE`. History is retained.
- **List Members**
  - `GET /api/v1/missions/{code}/personnel`
  - Auth: Active members of the mission or Officers.

### TARGETS
- **Create Target**: `POST /api/v1/missions/{code}/targets`
- **List Targets**: `GET /api/v1/missions/{code}/targets`
- **Update Target**: `PUT /api/v1/missions/{code}/targets/{id}`
- Auth: Read allowed for active members/officers; Create/Update strictly for Officers.

### ASSIGNMENTS
- **Create Assignment**: `POST /api/v1/missions/{code}/assignments`
- **List Assignments**: `GET /api/v1/missions/{code}/assignments`
- **Update Assignment**: `PUT /api/v1/missions/{code}/assignments/{id}`
- Auth: Read allowed for active members/officers; Create/Update strictly for Officers.

### LOCATION
- **Submit Location**
  - `POST /api/v1/missions/{code}/personnel/{personnelId}/location`
  - Auth: The authenticated user must own the `personnelId` and be an active member, or be an Officer.
- **Get Locations**
  - `GET /api/v1/missions/{code}/locations`
  - Auth: Active members of the mission or Officers.
  - Returns: DTO array containing the location and its computed `freshness` and `ageSeconds`.

### DASHBOARD
- **Mission Dashboard**
  - `GET /api/v1/missions/{code}/dashboard`
  - Purpose: Retrieves live aggregations (team counts, active members, progress, emergencies, inventory attention, and overall readiness score).

## 3. Security Documentation

- **Mission Authorization**: All reads (`GET`) check for either an `OFFICER` role or active membership in the requested mission. Cross-mission access is strictly blocked (`403 Forbidden`).
- **Mission Closure Constraint**: All operational mutations (`POST`, `PUT`, `DELETE`) are blocked if a mission is `CLOSED` or `COMPLETED`. The `MissionClosureFilter` enforces this globally returning `409 Conflict`.
- **Location Ownership**: Personnel can only submit locations for themselves unless authorized as an Officer.
- **Mission Code**: Serves as a path variable identifier, not an access password.
- **Audit Logging**: Operations like creating a mission, accessing a mission, and removing a member are logged via `AuditService`.

## 4. Location Freshness Thresholds

Configured inside `LocationFreshnessService`:
- **LIVE**: <= 60 seconds (1 minute).
- **RECENT**: <= 300 seconds (5 minutes).
- **STALE**: <= 1800 seconds (30 minutes).
- **OFFLINE**: > 1800 seconds, or automatically applied to all locations belonging to a `CLOSED` or `COMPLETED` mission regardless of timestamp, or if no location exists.
- *Upcoming Flutter Limitation*: Note that browser GPS limitations may impact actual reporting frequency in Phase 17B, which will be mitigated by service workers where possible.

## 5. Test Documentation

- **Automated Tests**: Validated the `MissionClosureFilter`, `MissionAccessService`, and `LocationFreshnessService` via unit tests, all of which execute cleanly during maven package builds.
- **Docker E2E Scenarios**: 
  - Complete lifecycle executed via custom Python test client communicating with fully deployed PostgreSQL + Spring Boot stack.
  - Scenarios verified: Valid creation flow, target/assignment tracking, dashboard data points aggregation, member removal access termination, mission closure constraints, and cross-mission access rejection.
- **Known Limitations**: 
  - Real browser-based GPS coordinate aggregation is deferred to Flutter frontend (Phase 17B).

## 6. Phase 17C Final Acceptance Notes

### Browser GPS Limitation
**Browser GPS not automatically verified** - The Flutter web implementation uses the browser's Geolocation API (`navigator.geolocation.getCurrentPosition`) which requires:
- Secure context (HTTPS or localhost)
- User permission grant
- Cannot be tested in headless/CI environments
- Manual verification required in a real browser

### Mission Code Verification
- Format: `POLAR-YYYY-NNN` (e.g., `POLAR-2026-001`)
- Generated server-side in `MissionController.create()`
- Not used as authentication credentials
- Path variable only, authorization via JWT + `MissionAccessService`

### HTTP Status Code Coverage
| Code | Scenario | Verified |
|------|----------|----------|
| 200 | Successful reads (missions, teams, members, locations, targets, assignments, dashboard) | ✅ |
| 201 | Successful creation (mission, team, member, target, assignment, location) | ✅ |
| 400 | Invalid request (missing required fields) | ✅ |
| 401 | Unauthenticated (no/malformed JWT) | ✅ |
| 403 | Unauthorized (non-member FIELD_OPERATOR, cross-mission) | ✅ |
| 404 | Not found (invalid mission code) | ✅ |
| 409 | Closed mission mutation (target/assignment/member/location) | ✅ |
| 5xx | Backend failure | N/A (not forced) |

### Files Changed in Phase 17C
- `polar-ops-backend/src/main/java/in/gov/moes/ncpor/polarops/controller/MissionController.java` - Added `GET /missions` and `GET /missions/{code}/teams` endpoints
- `polar_ops_web/lib/services/api/api_client.dart` - Added 409 friendly error message

### Verification Commands
```powershell
# Full API verification
$token = (Invoke-RestMethod -Method POST -Uri "http://localhost:8080/api/v1/auth/login" -ContentType "application/json" -Body '{"email":"admin@polarops.gov.in","password":"password"}').token
$headers = @{Authorization="Bearer $token"}

# 1. List missions
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions" -Headers $headers

# 2. Get mission
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001" -Headers $headers

# 3. Dashboard
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/dashboard" -Headers $headers

# 4. Teams
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/teams" -Headers $headers

# 5. Members
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/personnel" -Headers $headers

# 6. Targets
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/targets" -Headers $headers

# 7. Assignments
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/assignments" -Headers $headers

# 8. Locations (with freshness)
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/locations" -Headers $headers

# 9. Member removal
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/members/1" -Method DELETE -Headers $headers

# 10. Mission closure
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/close" -Method POST -Headers $headers

# 11. Closed mutation (expect 409)
$body = @{completedValue=100} | ConvertTo-Json
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001/targets/1" -Method PUT -Headers $headers -ContentType "application/json" -Body $body

# 12. Unauthenticated (expect 403)
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001"

# 13. Non-member FIELD_OPERATOR (expect 403)
$token = (Invoke-RestMethod -Method POST -Uri "http://localhost:8080/api/v1/auth/login" -ContentType "application/json" -Body '{"email":"field@polarops.gov.in","password":"password"}').token
$headers = @{Authorization="Bearer $token"}
Invoke-RestMethod -Uri "http://localhost:8080/api/v1/missions/POLAR-2026-001" -Headers $headers

# 14. Flutter verification
cd polar_ops_web
flutter pub get
flutter analyze --no-fatal-infos
flutter build web --release --no-wasm-dry-run

# 15. Docker verification
docker-compose ps
```

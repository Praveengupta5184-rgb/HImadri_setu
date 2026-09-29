import urllib.request
import urllib.error
import json

BASE_URL = "http://localhost:8080/api/v1"
ADMIN_EMAIL = "admin@polarops.gov.in"
ADMIN_PASS = "password"

def make_req(method, endpoint, payload=None, headers=None):
    url = BASE_URL + endpoint
    req_headers = {'Content-Type': 'application/json'}
    if headers:
        req_headers.update(headers)
        
    data = None
    if payload is not None:
        data = json.dumps(payload).encode('utf-8')
        
    req = urllib.request.Request(url, data=data, headers=req_headers, method=method)
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode('utf-8')
            status = resp.getcode()
            if body:
                try:
                    return status, json.loads(body)
                except:
                    return status, body
            return status, None
    except urllib.error.HTTPError as e:
        body = e.read().decode('utf-8')
        if body:
            try:
                return e.code, json.loads(body)
            except:
                return e.code, body
        return e.code, None

print("==================================================")
print("1. START CLEAN RUNNING STACK")
print("==================================================")

status, body = make_req("POST", "/auth/login", {"email": ADMIN_EMAIL, "password": ADMIN_PASS})
if status != 200:
    print(f"Failed to login: {body}")
    exit(1)
token = body["token"]
headers = {"Authorization": f"Bearer {token}"}
print(f"Logged in successfully.")

print("\n==================================================")
print("2. CREATE REAL TEST MISSION")
print("==================================================")
mission_data = {
    "missionName": "E2E Test Mission",
    "objective": "Complete verification",
    "startDate": "2026-09-01T00:00:00",
    "endDate": "2026-10-01T00:00:00",
    "expedition": {"id": 1}
}
status, mission = make_req("POST", "/missions", mission_data, headers)
print(f"Status: {status}")
if status != 201:
    print(mission)
    exit(1)
mission_code = mission["missionCode"]
print(f"Mission Code: {mission_code}")
print(f"Mission ID: {mission['id']}")
print(f"Status: {mission['status']}")

print("\n==================================================")
print("3. CREATE TEAM")
print("==================================================")
team_data = {
    "teamCode": "TEAM-E2E-01",
    "teamName": "E2E Alpha Team"
}
status, team = make_req("POST", f"/missions/{mission_code}/teams", team_data, headers)
print(f"Status: {status}")
if status != 201:
    print(team)
    exit(1)
team_id = team["id"]
print(f"Team ID: {team_id}")

print("\n==================================================")
print("4. ADD PERSONNEL")
print("==================================================")
personnel_id = 1
status, member = make_req("POST", f"/missions/{mission_code}/teams/{team_id}/members/{personnel_id}", None, headers)
print(f"Status: {status}")
if status != 201:
    print(member)
    exit(1)
print(f"Member ID: {member['id']} (Status: {member['membershipStatus']})")

print("\n==================================================")
print("5. CREATE TARGET")
print("==================================================")
target_data = {
    "team": {"id": team_id},
    "title": "E2E Target 1",
    "targetValue": 100,
    "completedValue": 0,
    "status": "PENDING"
}
status, target = make_req("POST", f"/missions/{mission_code}/targets", target_data, headers)
print(f"Status: {status}")
if status != 201:
    print(target)
    exit(1)
target_id = target["id"]
print(f"Target ID: {target_id}")

status, target_upd = make_req("PUT", f"/missions/{mission_code}/targets/{target_id}", {"completedValue": 50, "status": "IN_PROGRESS"}, headers)
print(f"Target Update Status: {status}")
print(f"Updated Target: {target_upd.get('completedValue')}")

print("\n==================================================")
print("6. CREATE ASSIGNMENT")
print("==================================================")
assignment_data = {
    "team": {"id": team_id},
    "personnel": {"id": personnel_id},
    "title": "E2E Task 1",
    "targetValue": 100,
    "completedValue": 0,
    "status": "ASSIGNED"
}
status, assignment = make_req("POST", f"/missions/{mission_code}/assignments", assignment_data, headers)
print(f"Status: {status}")
if status != 201:
    print(assignment)
    exit(1)
assignment_id = assignment["id"]
print(f"Assignment ID: {assignment_id}")

status, _ = make_req("PUT", f"/missions/{mission_code}/assignments/{assignment_id}", {"completedValue": 100, "status": "COMPLETED"}, headers)
print(f"Assignment Update Status: {status}")

print("\n==================================================")
print("7. REAL LOCATION SUBMISSION")
print("==================================================")
location_data = {
    "latitude": -78.1234,
    "longitude": 160.5678,
    "accuracyMeters": 5.0,
    "source": "DEVICE",
    "movementStatus": "STATIONARY"
}
status, _ = make_req("POST", f"/missions/{mission_code}/personnel/{personnel_id}/location", location_data, headers)
print(f"Status: {status}")
if status != 201:
    print(_)
    exit(1)
print(f"Location persisted.")

print("\n==================================================")
print("8. LOCATION FRESHNESS")
print("==================================================")
status, locs = make_req("GET", f"/missions/{mission_code}/locations", None, headers)
print(f"Locations GET Status: {status}")
if len(locs) > 0:
    print(f"Freshness: {locs[0].get('freshness')}")
    print(f"Age Seconds: {locs[0].get('ageSeconds')}")

print("\n==================================================")
print("9. MISSION DASHBOARD")
print("==================================================")
status, dash = make_req("GET", f"/missions/{mission_code}/dashboard", None, headers)
print(f"Status: {status}")
print(f"Teams: {dash.get('teamCount')}")
print(f"Active Personnel: {dash.get('activePersonnel')}")
print(f"Targets: {dash.get('targetCount')}")
print(f"Assignments: {dash.get('assignmentCount')}")

print("\n==================================================")
print("10. MEMBERSHIP REMOVAL")
print("==================================================")
status, _ = make_req("DELETE", f"/missions/{mission_code}/members/{personnel_id}", None, headers)
print(f"Remove Member Status: {status}")

f_status, f_body = make_req("POST", "/auth/login", {"email": "field@polarops.gov.in", "password": "password"})
field_headers = {"Authorization": f"Bearer {f_body['token']}"}

status, _ = make_req("GET", f"/missions/{mission_code}/dashboard", None, field_headers)
print(f"Field operator (not member) dashboard GET Status: {status}")
if status == 403:
    print("Rejected as expected.")

status, _ = make_req("POST", f"/missions/{mission_code}/personnel/{personnel_id}/location", location_data, field_headers)
print(f"Field operator location POST Status: {status}")

print("\n==================================================")
print("11. MISSION CLOSURE")
print("==================================================")
status, cls = make_req("POST", f"/missions/{mission_code}/close", None, headers)
print(f"Close Status: {status}")
if cls:
    print(f"Mission Status: {cls.get('status')}")

print("\n==================================================")
print("12. CLOSED MISSION MUTATION TEST")
print("==================================================")
status, _ = make_req("POST", f"/missions/{mission_code}/teams", team_data, headers)
print(f"Create Team Status: {status}")
print(_)

status, _ = make_req("POST", f"/missions/{mission_code}/teams/{team_id}/members/2", None, headers)
print(f"Add Member Status: {status}")
print(_)

status, _ = make_req("POST", f"/missions/{mission_code}/targets", target_data, headers)
print(f"Create Target Status: {status}")

status, _ = make_req("PUT", f"/missions/{mission_code}/targets/{target_id}", {"completedValue": 100, "status": "COMPLETED"}, headers)
print(f"Update Target Status: {status}")

status, _ = make_req("POST", f"/missions/{mission_code}/assignments", assignment_data, headers)
print(f"Create Assignment Status: {status}")

status, _ = make_req("PUT", f"/missions/{mission_code}/assignments/{assignment_id}", {"completedValue": 100, "status": "COMPLETED"}, headers)
print(f"Update Assignment Status: {status}")

status, _ = make_req("POST", f"/missions/{mission_code}/personnel/{personnel_id}/location", location_data, headers)
print(f"Submit Location Status: {status}")
print(_)

print("\n==================================================")
print("13. CROSS-MISSION SECURITY TEST")
print("==================================================")
mission2_data = mission_data.copy()
mission2_data["missionName"] = "E2E Mission 2"
status, mission2 = make_req("POST", "/missions", mission2_data, headers)
mission2_code = mission2["missionCode"]
print(f"Created second mission: {mission2_code}")

print("Trying to access Mission 2 dashboard as Field User...")
status, _ = make_req("GET", f"/missions/{mission2_code}/dashboard", None, field_headers)
print(f"Status: {status}")
if status == 403:
    print("Rejected as expected.")

print("\n==================================================")
print("ALL TESTS COMPLETE")
print("==================================================")

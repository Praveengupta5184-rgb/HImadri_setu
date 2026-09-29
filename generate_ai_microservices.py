import os

base_dir = "polar_ops_ai"
dirs = [
    "risk_score_service",
    "inventory_forecast_service",
    "damage_detection_service",
]

for d in dirs:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

def write_file(path, content):
    with open(os.path.join(base_dir, path), "w", encoding="utf-8") as f:
        f.write(content)

# 1. docker-compose.yml
write_file("docker-compose.yml", """version: '3.8'

services:
  risk_score_service:
    build: ./risk_score_service
    ports:
      - "8001:80"
    restart: unless-stopped

  inventory_forecast_service:
    build: ./inventory_forecast_service
    ports:
      - "8002:80"
    restart: unless-stopped

  damage_detection_service:
    build: ./damage_detection_service
    ports:
      - "8003:80"
    restart: unless-stopped
""")

# 2. Risk Score Service
write_file("risk_score_service/main.py", """from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime, timedelta
import random

app = FastAPI(title="Cargo Risk Score Service")

class CargoRiskInput(BaseModel):
    cargo_id: str
    deadline_days_remaining: int
    is_hazardous: bool
    packaging_quality_score: float
    weather_risk_score: float
    historical_delay_rate: float
    customs_complexity_score: float

class CargoRiskOutput(BaseModel):
    cargo_id: str
    risk_score: int
    risk_level: str
    factors: dict
    recommendations: list

@app.post("/api/risk-score", response_model=CargoRiskOutput)
def calculate_risk(input: CargoRiskInput):
    deadline_risk = max(0, 30 - input.deadline_days_remaining * 2)
    hazard_risk = 25 if input.is_hazardous else 0
    packaging_risk = int(input.packaging_quality_score * 20)
    weather_risk = int(input.weather_risk_score * 15)
    historical_risk = int(input.historical_delay_rate * 10)
    
    risk_score = min(100, deadline_risk + hazard_risk + packaging_risk + weather_risk + historical_risk)
    
    risk_level = "CRITICAL" if risk_score >= 75 else "HIGH" if risk_score >= 50 else "MEDIUM" if risk_score >= 25 else "LOW"
    
    recommendations = []
    if input.deadline_days_remaining < 10: recommendations.append("Expedite shipment")
    if input.is_hazardous: recommendations.append("Verify hazardous material documentation")
    if input.packaging_quality_score < 0.7: recommendations.append("Reinforce packaging")
    if risk_score >= 50: recommendations.append("Contact logistics provider")
    
    return CargoRiskOutput(
        cargo_id=input.cargo_id, risk_score=risk_score, risk_level=risk_level,
        factors={"deadline_risk": deadline_risk, "hazard_risk": hazard_risk, "packaging_risk": packaging_risk, "weather_risk": weather_risk, "historical_risk": historical_risk},
        recommendations=recommendations
    )
""")
write_file("risk_score_service/requirements.txt", "fastapi\nuvicorn\npydantic\n")
write_file("risk_score_service/Dockerfile", """FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
""")

# 3. Inventory Forecast Service
write_file("inventory_forecast_service/main.py", """from fastapi import FastAPI
from pydantic import BaseModel
import numpy as np

app = FastAPI(title="Inventory Forecasting Service")

class InventoryForecastInput(BaseModel):
    item_id: str
    historical_consumption: list
    personnel_count: int
    expedition_duration_days: int
    season: str

class InventoryForecastOutput(BaseModel):
    item_id: str
    predicted_consumption_30_days: int
    current_stock: int
    shortage_alert: bool
    confidence_interval_lower: int
    confidence_interval_upper: int
    recommended_procurement: int
    urgency: str

@app.post("/api/forecast", response_model=InventoryForecastOutput)
def forecast_inventory(input: InventoryForecastInput):
    avg_consumption = np.mean(input.historical_consumption) if input.historical_consumption else 2.5
    predicted_30_days = int(avg_consumption * 30)
    
    if input.season == "WINTER":
        predicted_30_days = int(predicted_30_days * 1.2)
    predicted_30_days = int(predicted_30_days * (input.personnel_count / 25))
    
    current_stock = 45 
    shortage_alert = current_stock < predicted_30_days
    
    return InventoryForecastOutput(
        item_id=input.item_id,
        predicted_consumption_30_days=predicted_30_days,
        current_stock=current_stock,
        shortage_alert=shortage_alert,
        confidence_interval_lower=int(predicted_30_days * 0.8),
        confidence_interval_upper=int(predicted_30_days * 1.2),
        recommended_procurement=max(0, predicted_30_days - current_stock + 60),
        urgency="HIGH" if shortage_alert else "NORMAL"
    )
""")
write_file("inventory_forecast_service/requirements.txt", "fastapi\nuvicorn\npydantic\nnumpy\nprophet\npandas\n")
write_file("inventory_forecast_service/Dockerfile", """FROM python:3.9-slim
WORKDIR /app
# Install system deps for Prophet/numpy
RUN apt-get update && apt-get install -y build-essential
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
""")

# 4. Damage Detection Service
write_file("damage_detection_service/main.py", """from fastapi import FastAPI, UploadFile, File
from pydantic import BaseModel
import cv2
import numpy as np

app = FastAPI(title="Damage Detection Service")

class DamageDetectionOutput(BaseModel):
    is_damaged: bool
    damage_type: list
    confidence: float
    recommendation: str

@app.post("/api/detect-damage", response_model=DamageDetectionOutput)
async def detect_damage(file: UploadFile = File(...)):
    contents = await file.read()
    nparr = np.frombuffer(contents, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    _, dark_spots = cv2.threshold(gray, 50, 255, cv2.THRESH_BINARY_INV)
    num_dark_spots = cv2.countNonZero(dark_spots)
    
    is_damaged = num_dark_spots > 1000
    damage_type = ["DENT"] if is_damaged else []
    confidence = min(0.95, num_dark_spots / 5000) if is_damaged else 0.0
    
    return DamageDetectionOutput(
        is_damaged=is_damaged,
        damage_type=damage_type,
        confidence=confidence,
        recommendation="Manual inspection required" if is_damaged else "Package appears undamaged"
    )
""")
write_file("damage_detection_service/requirements.txt", "fastapi\nuvicorn\npydantic\nopencv-python-headless\nnumpy\npython-multipart\n")
write_file("damage_detection_service/Dockerfile", """FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
""")

print("Successfully generated all AI microservices.")

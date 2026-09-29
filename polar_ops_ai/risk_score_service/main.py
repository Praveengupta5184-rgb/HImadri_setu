from fastapi import FastAPI
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

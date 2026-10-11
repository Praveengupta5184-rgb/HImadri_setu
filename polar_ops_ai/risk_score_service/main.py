from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor, RandomForestClassifier
from sklearn.preprocessing import StandardScaler
import joblib
import os
from datetime import datetime

app = FastAPI(title="Mission Risk Intelligence Service")

MODEL_PATH = "/app/models/mission_risk_model.joblib"
SCALER_PATH = "/app/models/mission_risk_scaler.joblib"

class MissionRiskInput(BaseModel):
    mission_id: str
    weather_risk_score: float = 0.0
    cargo_delay_risk: float = 0.0
    inventory_shortage_risk: float = 0.0
    personnel_shortage_risk: float = 0.0
    active_emergencies: int = 0
    critical_asset_condition: float = 1.0
    location_risk_score: float = 0.0
    mission_duration_days: int = 30
    team_size: int = 10

class FactorContribution(BaseModel):
    name: str
    contribution: float
    explanation: str

class MissionRiskOutput(BaseModel):
    mission_id: str
    mission_risk_score: int
    risk_level: str
    factors: List[FactorContribution]
    confidence: float
    ai_mode: str
    model_version: str
    assessed_at: str

def extract_features(input: MissionRiskInput) -> np.ndarray:
    features = {
        'weather_risk_score': input.weather_risk_score,
        'cargo_delay_risk': input.cargo_delay_risk,
        'inventory_shortage_risk': input.inventory_shortage_risk,
        'personnel_shortage_risk': input.personnel_shortage_risk,
        'active_emergencies': input.active_emergencies,
        'critical_asset_condition': input.critical_asset_condition,
        'location_risk_score': input.location_risk_score,
        'mission_duration_days': input.mission_duration_days,
        'team_size': input.team_size,
        'emergency_per_person': input.active_emergencies / max(1, input.team_size),
    }
    return np.array(list(features.values())).reshape(1, -1)

def generate_synthetic_training_data(n_samples: int = 3000) -> tuple:
    np.random.seed(42)
    X = []
    y = []
    
    for _ in range(n_samples):
        weather = np.random.uniform(0, 1)
        cargo = np.random.uniform(0, 1)
        inventory = np.random.uniform(0, 1)
        personnel = np.random.uniform(0, 1)
        emergencies = np.random.randint(0, 5)
        asset = np.random.uniform(0.3, 1.0)
        location = np.random.uniform(0, 1)
        duration = np.random.randint(7, 180)
        team = np.random.randint(5, 50)
        
        features = {
            'weather_risk_score': weather,
            'cargo_delay_risk': cargo,
            'inventory_shortage_risk': inventory,
            'personnel_shortage_risk': personnel,
            'active_emergencies': emergencies,
            'critical_asset_condition': asset,
            'location_risk_score': location,
            'mission_duration_days': duration,
            'team_size': team,
            'emergency_per_person': emergencies / max(1, team),
        }
        X.append(list(features.values()))
        
        # Calculate risk score based on weighted factors
        risk = (weather * 25 + cargo * 20 + inventory * 20 + personnel * 15 + 
                emergencies * 8 + (1 - asset) * 10 + location * 10)
        risk = min(100, max(0, risk + np.random.normal(0, 5)))
        y.append(risk)
    
    return np.array(X), np.array(y)

def train_model():
    os.makedirs("/app/models", exist_ok=True)
    
    if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH):
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        return model, scaler
    
    X, y = generate_synthetic_training_data(5000)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    model = GradientBoostingRegressor(
        n_estimators=150,
        learning_rate=0.1,
        max_depth=6,
        random_state=42
    )
    model.fit(X_scaled, y)
    
    joblib.dump(model, MODEL_PATH)
    joblib.dump(scaler, SCALER_PATH)
    
    return model, scaler

def deterministic_risk_calculation(input: MissionRiskInput) -> dict:
    """Deterministic fallback risk calculation with explainable factors"""
    factors = []
    
    # Weather risk contribution
    weather_contrib = input.weather_risk_score * 25
    if weather_contrib > 0:
        factors.append({
            "name": "Weather",
            "contribution": round(weather_contrib, 1),
            "explanation": f"Weather risk score: {input.weather_risk_score:.2f} - {'Severe conditions' if input.weather_risk_score > 0.7 else 'Elevated risk' if input.weather_risk_score > 0.4 else 'Monitor'}"
        })
    
    # Cargo delay risk contribution
    cargo_contrib = input.cargo_delay_risk * 20
    if cargo_contrib > 0:
        factors.append({
            "name": "Cargo Delays",
            "contribution": round(cargo_contrib, 1),
            "explanation": f"Cargo delay probability: {input.cargo_delay_risk*100:.0f}% - {'Critical delays expected' if input.cargo_delay_risk > 0.7 else 'Significant delays likely' if input.cargo_delay_risk > 0.4 else 'Monitor shipments'}"
        })
    
    # Inventory shortage risk contribution
    inventory_contrib = input.inventory_shortage_risk * 20
    if inventory_contrib > 0:
        factors.append({
            "name": "Inventory Shortage",
            "contribution": round(inventory_contrib, 1),
            "explanation": f"Shortage probability: {input.inventory_shortage_risk*100:.0f}% - {'Critical stockouts projected' if input.inventory_shortage_risk > 0.7 else 'Shortages likely' if input.inventory_shortage_risk > 0.4 else 'Monitor consumption'}"
        })
    
    # Personnel shortage risk contribution
    personnel_contrib = input.personnel_shortage_risk * 15
    if personnel_contrib > 0:
        factors.append({
            "name": "Personnel Gaps",
            "contribution": round(personnel_contrib, 1),
            "explanation": f"Personnel risk: {input.personnel_shortage_risk:.2f} - {'Critical staffing shortage' if input.personnel_shortage_risk > 0.7 else 'Staffing gaps identified' if input.personnel_shortage_risk > 0.4 else 'Adequate staffing'}"
        })
    
    # Active emergencies contribution
    emergency_contrib = min(input.active_emergencies * 8, 25)
    if emergency_contrib > 0:
        factors.append({
            "name": "Active Emergencies",
            "contribution": round(emergency_contrib, 1),
            "explanation": f"{input.active_emergencies} active emergency incident(s) - {'Multiple concurrent emergencies' if input.active_emergencies > 2 else 'Emergency response ongoing' if input.active_emergencies > 0 else 'No active emergencies'}"
        })
    
    # Asset condition contribution
    asset_contrib = (1 - input.critical_asset_condition) * 10
    if asset_contrib > 0:
        factors.append({
            "name": "Asset Condition",
            "contribution": round(asset_contrib, 1),
            "explanation": f"Critical asset health: {input.critical_asset_condition*100:.0f}% - {'Multiple assets degraded' if input.critical_asset_condition < 0.5 else 'Some assets need attention' if input.critical_asset_condition < 0.8 else 'Assets operational'}"
        })
    
    # Location risk contribution
    location_contrib = input.location_risk_score * 10
    if location_contrib > 0:
        factors.append({
            "name": "Location Risk",
            "contribution": round(location_contrib, 1),
            "explanation": f"Mission location risk: {input.location_risk_score:.2f} - {'High risk environment' if input.location_risk_score > 0.7 else 'Elevated environmental risk' if input.location_risk_score > 0.4 else 'Standard polar conditions'}"
        })
    
    # Normalize contributions to sum to total risk score
    total_contrib = sum(f["contribution"] for f in factors)
    if total_contrib > 0:
        for f in factors:
            f["contribution"] = round(f["contribution"] / total_contrib * 100, 1)
    
    mission_risk_score = int(sum(f["contribution"] for f in factors))
    mission_risk_score = min(100, max(0, mission_risk_score))
    
    risk_level = "LOW"
    if mission_risk_score > 75: risk_level = "CRITICAL"
    elif mission_risk_score > 50: risk_level = "HIGH"
    elif mission_risk_score > 25: risk_level = "MODERATE"
    
    return {
        "mission_risk_score": mission_risk_score,
        "risk_level": risk_level,
        "factors": factors,
        "confidence": 0.78
    }

# Initialize model
model, scaler = train_model()

@app.get("/health")
def health():
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/api/assess-mission-risk", response_model=MissionRiskOutput)
def assess_mission_risk(input: MissionRiskInput):
    try:
        features = extract_features(input)
        features_scaled = scaler.transform(features)
        
        mission_risk_score = int(max(0, min(100, model.predict(features_scaled)[0])))
        
        risk_level = "LOW"
        if mission_risk_score > 75: risk_level = "CRITICAL"
        elif mission_risk_score > 50: risk_level = "HIGH"
        elif mission_risk_score > 25: risk_level = "MODERATE"
        
        # Get feature importances for explainability
        importances = model.feature_importances_
        feature_names = ['Weather', 'Cargo Delays', 'Inventory Shortage', 'Personnel Gaps', 
                        'Active Emergencies', 'Asset Condition', 'Location Risk', 
                        'Mission Duration', 'Team Size', 'Emergency Density']
        
        # Calculate factor contributions from feature importances
        raw_features = features.flatten()
        factors = []
        for i, (name, importance) in enumerate(zip(feature_names, importances)):
            if importance > 0.02 and raw_features[i] > 0:
                contribution = importance * 100
                # Generate explanation based on feature
                explanations = {
                    'Weather': f"Weather risk score: {raw_features[i]:.2f}",
                    'Cargo Delays': f"Cargo delay risk: {raw_features[i]*100:.0f}%",
                    'Inventory Shortage': f"Inventory shortage risk: {raw_features[i]*100:.0f}%",
                    'Personnel Gaps': f"Personnel shortage risk: {raw_features[i]*100:.0f}%",
                    'Active Emergencies': f"{int(raw_features[i])} active emergencies",
                    'Asset Condition': f"Asset health: {raw_features[i]*100:.0f}%",
                    'Location Risk': f"Location risk score: {raw_features[i]:.2f}",
                    'Mission Duration': f"Mission duration: {int(raw_features[i])} days",
                    'Team Size': f"Team size: {int(raw_features[i])}",
                    'Emergency Density': f"Emergencies per person: {raw_features[i]:.2f}"
                }
                factors.append(FactorContribution(
                    name=name,
                    contribution=round(contribution, 1),
                    explanation=explanations.get(name, "")
                ))
        
        # Normalize contributions
        total = sum(f.contribution for f in factors)
        if total > 0:
            for f in factors:
                f.contribution = round(f.contribution / total * 100, 1)
        
        ai_mode = "ML"
        confidence = 0.85
        
    except Exception as e:
        result = deterministic_risk_calculation(input)
        mission_risk_score = result["mission_risk_score"]
        risk_level = result["risk_level"]
        factors = [FactorContribution(**f) for f in result["factors"]]
        confidence = result["confidence"]
        ai_mode = "RULE_BASED_FALLBACK"
    
    return MissionRiskOutput(
        mission_id=input.mission_id,
        mission_risk_score=mission_risk_score,
        risk_level=risk_level,
        factors=factors,
        confidence=round(confidence, 2),
        ai_mode=ai_mode,
        model_version="1.0.0",
        assessed_at=datetime.now().isoformat()
    )
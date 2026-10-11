from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler
import joblib
import os
from datetime import datetime, timedelta

app = FastAPI(title="Predictive Logistics Service")

MODEL_PATH = "/app/models/logistics_delay_model.joblib"
SCALER_PATH = "/app/models/logistics_scaler.joblib"

class CargoLogisticsInput(BaseModel):
    cargo_id: str
    deadline_days_remaining: int
    current_status: str
    destination: str
    is_hazardous: bool
    historical_delay_rate: float = 0.0
    transit_duration_hours: float
    weather_risk_score: float = 0.0
    packaging_condition_score: float = 1.0
    previous_inspection_passed: bool = True
    logistics_provider: Optional[str] = None

class CargoLogisticsOutput(BaseModel):
    cargo_id: str
    delay_probability: float
    predicted_delay_hours: float
    criticality_score: int
    risk_level: str
    confidence: float
    factors: Dict[str, float]
    recommendations: List[str]
    ai_mode: str
    model_version: str

def extract_features(input: CargoLogisticsInput) -> np.ndarray:
    """Extract features for delay prediction"""
    features = {
        'deadline_days_remaining': input.deadline_days_remaining,
        'is_hazardous': 1 if input.is_hazardous else 0,
        'historical_delay_rate': input.historical_delay_rate,
        'transit_duration_hours': input.transit_duration_hours,
        'weather_risk_score': input.weather_risk_score,
        'packaging_condition_score': input.packaging_condition_score,
        'previous_inspection_passed': 1 if input.previous_inspection_passed else 0,
        'status_delayed': 1 if input.current_status.upper() == "DELAYED" else 0,
        'status_in_transit': 1 if input.current_status.upper() == "IN_TRANSIT" else 0,
        'status_pending': 1 if input.current_status.upper() == "PENDING" else 0,
    }
    return np.array(list(features.values())).reshape(1, -1)

def get_feature_names() -> List[str]:
    return ['deadline_days_remaining', 'is_hazardous', 'historical_delay_rate', 
            'transit_duration_hours', 'weather_risk_score', 'packaging_condition_score',
            'previous_inspection_passed', 'status_delayed', 'status_in_transit', 'status_pending']

def generate_synthetic_training_data(n_samples: int = 2000) -> tuple:
    """Generate synthetic training data for delay prediction"""
    np.random.seed(42)
    X = []
    y_delay = []
    y_hours = []
    
    for _ in range(n_samples):
        deadline = np.random.randint(-5, 60)
        hazardous = np.random.choice([0, 1], p=[0.8, 0.2])
        hist_delay = np.random.uniform(0, 0.5)
        transit = np.random.uniform(24, 720)
        weather = np.random.uniform(0, 1)
        packaging = np.random.uniform(0.3, 1.0)
        inspection = np.random.choice([0, 1], p=[0.1, 0.9])
        status = np.random.choice([0, 1, 2])  # delayed, in_transit, pending
        
        features = {
            'deadline_days_remaining': deadline,
            'is_hazardous': hazardous,
            'historical_delay_rate': hist_delay,
            'transit_duration_hours': transit,
            'weather_risk_score': weather,
            'packaging_condition_score': packaging,
            'previous_inspection_passed': inspection,
            'status_delayed': 1 if status == 0 else 0,
            'status_in_transit': 1 if status == 1 else 0,
            'status_pending': 1 if status == 2 else 0,
        }
        X.append(list(features.values()))
        
        # Calculate delay probability
        delay_prob = 0.1
        if deadline < 0: delay_prob += 0.4
        elif deadline < 7: delay_prob += 0.2
        if hazardous: delay_prob += 0.15
        delay_prob += hist_delay * 0.3
        delay_prob += weather * 0.15
        delay_prob += (1 - packaging) * 0.1
        if not inspection: delay_prob += 0.1
        if status == 0: delay_prob += 0.3
        delay_prob = min(0.95, max(0.05, delay_prob))
        
        y_delay.append(1 if delay_prob > 0.5 else 0)
        
        # Predicted delay hours
        base_delay = max(0, -deadline) * 24 if deadline < 0 else 0
        delay_hours = base_delay + np.random.exponential(12) * delay_prob * 2
        y_hours.append(delay_hours)
    
    return np.array(X), np.array(y_delay), np.array(y_hours)

def train_models():
    """Train delay classification and regression models"""
    os.makedirs("/app/models", exist_ok=True)
    
    if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH):
        model_data = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        return model_data['classifier'], model_data['regressor'], scaler
    
    X, y_delay, y_hours = generate_synthetic_training_data(3000)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # Classification model for delay probability
    classifier = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42,
        class_weight='balanced'
    )
    classifier.fit(X_scaled, y_delay)
    
    # Regression model for delay hours
    regressor = GradientBoostingRegressor(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        random_state=42
    )
    regressor.fit(X_scaled, y_hours)
    
    model_data = {
        'classifier': classifier,
        'regressor': regressor
    }
    joblib.dump(model_data, MODEL_PATH)
    joblib.dump(scaler, SCALER_PATH)
    
    return classifier, regressor, scaler

def deterministic_prediction(input: CargoLogisticsInput) -> dict:
    """Deterministic fallback prediction"""
    delay_prob = 0.1
    
    if input.deadline_days_remaining < 0:
        delay_prob += 0.4
    elif input.deadline_days_remaining < 7:
        delay_prob += 0.2
    elif input.deadline_days_remaining < 14:
        delay_prob += 0.1
    
    if input.is_hazardous:
        delay_prob += 0.15
    
    delay_prob += input.historical_delay_rate * 0.3
    delay_prob += input.weather_risk_score * 0.15
    delay_prob += (1 - input.packaging_condition_score) * 0.1
    
    if not input.previous_inspection_passed:
        delay_prob += 0.1
    
    if input.current_status.upper() == "DELAYED":
        delay_prob += 0.3
    elif input.current_status.upper() == "IN_TRANSIT":
        delay_prob += 0.1
    
    delay_prob = min(0.95, max(0.05, delay_prob))
    
    # Predicted delay hours
    base_delay = max(0, -input.deadline_days_remaining) * 24 if input.deadline_days_remaining < 0 else 0
    predicted_delay = base_delay + delay_prob * 48
    
    # Criticality score
    criticality = int(delay_prob * 50 + (input.is_hazardous * 20) + (input.weather_risk_score * 15) + 
                     (1 - input.packaging_condition_score) * 15)
    criticality = min(100, max(0, criticality))
    
    risk_level = "LOW"
    if criticality > 75: risk_level = "CRITICAL"
    elif criticality > 50: risk_level = "HIGH"
    elif criticality > 25: risk_level = "MODERATE"
    
    factors = {
        "deadlinePressure": round(max(0, (7 - input.deadline_days_remaining) / 7 * 30), 1) if input.deadline_days_remaining < 7 else 0,
        "hazardousMaterial": 15 if input.is_hazardous else 0,
        "historicalDelays": round(input.historical_delay_rate * 20, 1),
        "weatherRisk": round(input.weather_risk_score * 15, 1),
        "packagingQuality": round((1 - input.packaging_condition_score) * 10, 1),
        "inspectionStatus": 0 if input.previous_inspection_passed else 10,
    }
    
    recommendations = []
    if input.deadline_days_remaining < 10:
        recommendations.append("Expedite shipment - deadline approaching")
    if input.is_hazardous:
        recommendations.append("Verify hazardous material documentation")
    if input.packaging_condition_score < 0.7:
        recommendations.append("Reinforce packaging before transit")
    if input.weather_risk_score > 0.6:
        recommendations.append("Monitor weather conditions closely")
    if delay_prob > 0.5:
        recommendations.append("Contact logistics provider for contingency planning")
    
    return {
        "delay_prob": delay_prob * 100,
        "predicted_delay": predicted_delay,
        "criticality": criticality,
        "risk_level": risk_level,
        "confidence": 0.75,
        "factors": factors,
        "recommendations": recommendations
    }

# Initialize models
classifier, regressor, scaler = train_models()

@app.get("/health")
def health():
    return {"status": "healthy", "models_loaded": classifier is not None}

@app.post("/api/predict-delay", response_model=CargoLogisticsOutput)
def predict_delay(input: CargoLogisticsInput):
    try:
        features = extract_features(input)
        features_scaled = scaler.transform(features)
        
        # Get delay probability from classifier
        delay_prob = classifier.predict_proba(features_scaled)[0][1] * 100
        
        # Get predicted delay hours from regressor
        predicted_delay = max(0, regressor.predict(features_scaled)[0])
        
        # Criticality score
        criticality = int(delay_prob * 0.5 + (input.is_hazardous * 20) + (input.weather_risk_score * 15) + 
                         (1 - input.packaging_condition_score) * 15 + 
                         (1 if input.current_status.upper() == "DELAYED" else 0) * 20)
        criticality = min(100, max(0, criticality))
        
        risk_level = "LOW"
        if criticality > 75: risk_level = "CRITICAL"
        elif criticality > 50: risk_level = "HIGH"
        elif criticality > 25: risk_level = "MODERATE"
        
        factors = {
            "deadlinePressure": round(max(0, (7 - input.deadline_days_remaining) / 7 * 30), 1) if input.deadline_days_remaining < 7 else 0,
            "hazardousMaterial": 15 if input.is_hazardous else 0,
            "historicalDelays": round(input.historical_delay_rate * 20, 1),
            "weatherRisk": round(input.weather_risk_score * 15, 1),
            "packagingQuality": round((1 - input.packaging_condition_score) * 10, 1),
            "inspectionStatus": 0 if input.previous_inspection_passed else 10,
        }
        
        recommendations = []
        if input.deadline_days_remaining < 10:
            recommendations.append("Expedite shipment - deadline approaching")
        if input.is_hazardous:
            recommendations.append("Verify hazardous material documentation")
        if input.packaging_condition_score < 0.7:
            recommendations.append("Reinforce packaging before transit")
        if input.weather_risk_score > 0.6:
            recommendations.append("Monitor weather conditions closely")
        if delay_prob > 50:
            recommendations.append("Contact logistics provider for contingency planning")
        
        ai_mode = "ML"
        confidence = 0.87
        
    except Exception as e:
        result = deterministic_prediction(input)
        delay_prob = result["delay_prob"]
        predicted_delay = result["predicted_delay"]
        criticality = result["criticality"]
        risk_level = result["risk_level"]
        confidence = result["confidence"]
        factors = result["factors"]
        recommendations = result["recommendations"]
        ai_mode = "RULE_BASED_FALLBACK"
    
    return CargoLogisticsOutput(
        cargo_id=input.cargo_id,
        delay_probability=round(delay_prob, 1),
        predicted_delay_hours=round(predicted_delay, 1),
        criticality_score=criticality,
        risk_level=risk_level,
        confidence=round(confidence, 2),
        factors=factors,
        recommendations=recommendations,
        ai_mode=ai_mode,
        model_version="1.0.0"
    )
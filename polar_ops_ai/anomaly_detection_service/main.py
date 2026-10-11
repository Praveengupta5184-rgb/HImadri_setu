from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import numpy as np
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
import joblib
import os
from datetime import datetime

app = FastAPI(title="Anomaly Detection Service")

MODEL_PATH = "/app/models/anomaly_model.joblib"
SCALER_PATH = "/app/models/anomaly_scaler.joblib"

class AnomalyDetectionInput(BaseModel):
    entity_type: str  # "cargo", "inventory", "personnel", "weather", "asset"
    entity_id: str
    features: Dict[str, float]
    timestamp: Optional[str] = None

class AnomalyDetectionOutput(BaseModel):
    entity_type: str
    entity_id: str
    anomaly_score: float
    is_anomaly: bool
    anomaly_type: str
    severity: str
    explanation: str
    detected_at: str
    ai_mode: str
    model_version: str

def train_model():
    """Train IsolationForest model for anomaly detection"""
    os.makedirs("/app/models", exist_ok=True)
    
    if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH):
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        return model, scaler
    
    # Generate synthetic training data
    np.random.seed(42)
    n_samples = 5000
    n_features = 10
    
    # Normal data
    normal_data = np.random.normal(0, 1, (int(n_samples * 0.9), n_features))
    
    # Anomalous data
    anomaly_data = np.random.normal(3, 1.5, (int(n_samples * 0.1), n_features))
    
    X = np.vstack([normal_data, anomaly_data])
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    model = IsolationForest(
        n_estimators=100,
        contamination=0.1,
        random_state=42,
        max_samples='auto'
    )
    model.fit(X_scaled)
    
    joblib.dump(model, MODEL_PATH)
    joblib.dump(scaler, SCALER_PATH)
    
    return model, scaler

def extract_features(entity_type: str, features: Dict[str, float]) -> np.ndarray:
    """Extract standardized feature vector based on entity type"""
    # Define expected features for each entity type
    expected_features = {
        "cargo": ["delay_hours", "weight", "hazardous", "transit_duration", "weather_risk", 
                  "packaging_score", "inspection_score", "days_to_deadline", "provider_reliability", "status_code"],
        "inventory": ["consumption_rate", "stock_level", "min_stock", "personnel_count", "season_factor",
                      "days_since_restock", "expiry_proximity", "demand_trend", "supplier_lead_time", "criticality"],
        "personnel": ["location_accuracy", "movement_frequency", "battery_level", "signal_strength",
                      "time_since_update", "distance_from_base", "activity_level", "health_score", "mission_duration", "team_size"],
        "weather": ["temperature", "wind_speed", "humidity", "pressure", "visibility",
                    "precipitation", "storm_probability", "temperature_trend", "wind_trend", "severity_index"],
        "asset": ["operational_hours", "maintenance_due", "failure_count", "condition_score",
                  "usage_intensity", "age", "last_service_days", "criticality", "redundancy", "environment_score"]
    }
    
    feature_names = expected_features.get(entity_type, [f"feature_{i}" for i in range(10)])
    feature_vector = []
    
    for fname in feature_names:
        feature_vector.append(features.get(fname, 0.0))
    
    return np.array(feature_vector).reshape(1, -1)

def deterministic_anomaly_detection(entity_type: str, entity_id: str, features: Dict[str, float]) -> dict:
    """Rule-based anomaly detection fallback"""
    anomaly_score = 0.0
    anomaly_type = "NONE"
    severity = "LOW"
    explanation = "No anomalies detected"
    
    if entity_type == "cargo":
        if features.get("delay_hours", 0) > 48:
            anomaly_score = 0.8
            anomaly_type = "EXCESSIVE_DELAY"
            severity = "HIGH"
            explanation = f"Cargo delayed by {features.get('delay_hours')} hours"
        elif features.get("days_to_deadline", 30) < 0:
            anomaly_score = 0.9
            anomaly_type = "OVERDUE_DELIVERY"
            severity = "CRITICAL"
            explanation = "Cargo delivery is overdue"
        elif features.get("weather_risk", 0) > 0.8:
            anomaly_score = 0.6
            anomaly_type = "WEATHER_RISK"
            severity = "MODERATE"
            explanation = "Severe weather conditions affecting cargo"
            
    elif entity_type == "inventory":
        stock_ratio = features.get("stock_level", 100) / max(1, features.get("min_stock", 50))
        if stock_ratio < 0.5:
            anomaly_score = 0.85
            anomaly_type = "CRITICAL_STOCK_SHORTAGE"
            severity = "CRITICAL"
            explanation = f"Stock level at {stock_ratio*100:.0f}% of minimum"
        elif stock_ratio < 1.0:
            anomaly_score = 0.6
            anomaly_type = "LOW_STOCK"
            severity = "HIGH"
            explanation = f"Stock level below minimum threshold"
        elif features.get("consumption_rate", 0) > features.get("demand_trend", 1) * 2:
            anomaly_score = 0.5
            anomaly_type = "UNUSUAL_CONSUMPTION_SPIKE"
            severity = "MODERATE"
            explanation = "Consumption rate significantly higher than trend"
            
    elif entity_type == "personnel":
        if features.get("time_since_update", 0) > 1800:  # 30 minutes
            anomaly_score = 0.7
            anomaly_type = "STALE_LOCATION"
            severity = "MODERATE"
            explanation = "Personnel location not updated recently"
        elif features.get("battery_level", 100) < 10:
            anomaly_score = 0.5
            anomaly_type = "LOW_BATTERY"
            severity = "LOW"
            explanation = "Device battery critically low"
        elif features.get("health_score", 100) < 50:
            anomaly_score = 0.8
            anomaly_type = "HEALTH_CONCERN"
            severity = "HIGH"
            explanation = "Personnel health score indicates concern"
            
    elif entity_type == "weather":
        if features.get("storm_probability", 0) > 0.8:
            anomaly_score = 0.75
            anomaly_type = "STORM_WARNING"
            severity = "HIGH"
            explanation = "High probability of severe storm"
        elif features.get("wind_speed", 0) > 80:
            anomaly_score = 0.7
            anomaly_type = "GALE_FORCE_WINDS"
            severity = "HIGH"
            explanation = f"Wind speed {features.get('wind_speed')} km/h exceeds safe limits"
            
    elif entity_type == "asset":
        if features.get("condition_score", 100) < 30:
            anomaly_score = 0.7
            anomaly_type = "ASSET_DEGRADED"
            severity = "HIGH"
            explanation = "Asset condition below operational threshold"
        elif features.get("maintenance_due", 0) > 1:
            anomaly_score = 0.5
            anomaly_type = "MAINTENANCE_OVERDUE"
            severity = "MODERATE"
            explanation = "Asset maintenance is overdue"
    
    return {
        "anomaly_score": anomaly_score,
        "is_anomaly": anomaly_score > 0.5,
        "anomaly_type": anomaly_type,
        "severity": severity,
        "explanation": explanation
    }

# Initialize model
model, scaler = train_model()

@app.get("/health")
def health():
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/api/detect-anomaly", response_model=AnomalyDetectionOutput)
def detect_anomaly(input: AnomalyDetectionInput):
    try:
        features = extract_features(input.entity_type, input.features)
        features_scaled = scaler.transform(features)
        
        # Get anomaly score (negative = more anomalous)
        score = model.decision_function(features_scaled)[0]
        # Convert to 0-1 scale (0 = normal, 1 = anomalous)
        anomaly_score = max(0, min(1, (0.5 - score) / 0.5))
        is_anomaly = model.predict(features_scaled)[0] == -1
        
        # Determine anomaly type and severity based on score and entity type
        if anomaly_score > 0.8:
            severity = "CRITICAL"
        elif anomaly_score > 0.6:
            severity = "HIGH"
        elif anomaly_score > 0.4:
            severity = "MODERATE"
        else:
            severity = "LOW"
        
        anomaly_types = {
            "cargo": "CARGO_ANOMALY",
            "inventory": "INVENTORY_ANOMALY",
            "personnel": "PERSONNEL_ANOMALY",
            "weather": "WEATHER_ANOMALY",
            "asset": "ASSET_ANOMALY"
        }
        
        explanation = f"ML-detected anomaly with score {anomaly_score:.2f}"
        if is_anomaly:
            explanation = f"Anomalous pattern detected in {input.entity_type} {input.entity_id} (score: {anomaly_score:.2f})"
        
        ai_mode = "ML"
        confidence = 0.85
        
    except Exception as e:
        result = deterministic_anomaly_detection(input.entity_type, input.entity_id, input.features)
        anomaly_score = result["anomaly_score"]
        is_anomaly = result["is_anomaly"]
        severity = result["severity"]
        explanation = result["explanation"]
        anomaly_type = result["anomaly_type"]
        ai_mode = "RULE_BASED_FALLBACK"
        confidence = 0.70
    
    return AnomalyDetectionOutput(
        entity_type=input.entity_type,
        entity_id=input.entity_id,
        anomaly_score=round(anomaly_score, 3),
        is_anomaly=is_anomaly,
        anomaly_type=anomaly_types.get(input.entity_type, "UNKNOWN_ANOMALY") if is_anomaly else "NONE",
        severity=severity,
        explanation=explanation,
        detected_at=datetime.now().isoformat(),
        ai_mode=ai_mode,
        model_version="1.0.0"
    )
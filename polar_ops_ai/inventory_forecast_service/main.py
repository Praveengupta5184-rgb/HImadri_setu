from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import joblib
import os
import json
from datetime import datetime, timedelta

app = FastAPI(title="Inventory Forecasting Service")

MODEL_PATH = "/app/models/inventory_forecast_model.joblib"
SCALER_PATH = "/app/models/scaler.joblib"

class InventoryForecastInput(BaseModel):
    item_id: str
    historical_consumption: List[float] = Field(default_factory=list)
    personnel_count: int = 25
    expedition_duration_days: int = 90
    season: str = "SUMMER"
    current_stock: int
    minimum_stock: int
    mission_context: Optional[str] = None

class InventoryForecastOutput(BaseModel):
    item_id: str
    predicted_consumption_30_days: int
    shortage_probability: float
    confidence: float
    expected_shortage_date: Optional[str]
    recommended_procurement: int
    urgency: str
    factors: Dict[str, float]
    ai_mode: str
    model_version: str

def extract_features(historical: List[float], personnel: int, season: str) -> np.ndarray:
    """Extract features from historical consumption data"""
    if len(historical) == 0:
        historical = [2.5] * 30
    
    arr = np.array(historical)
    
    features = {
        'mean': np.mean(arr),
        'std': np.std(arr) if len(arr) > 1 else 0,
        'trend': np.polyfit(np.arange(len(arr)), arr, 1)[0] if len(arr) > 1 else 0,
        'rolling_mean_7': np.mean(arr[-7:]) if len(arr) >= 7 else np.mean(arr),
        'rolling_std_7': np.std(arr[-7:]) if len(arr) >= 7 else 0,
        'rolling_mean_30': np.mean(arr[-30:]) if len(arr) >= 30 else np.mean(arr),
        'personnel_count': personnel,
        'season_winter': 1 if season == "WINTER" else 0,
        'season_summer': 1 if season == "SUMMER" else 0,
        'season_spring': 1 if season == "SPRING" else 0,
        'season_autumn': 1 if season == "AUTUMN" else 0,
        'max_consumption': np.max(arr),
        'min_consumption': np.min(arr),
        'recent_trend': np.polyfit(np.arange(min(7, len(arr))), arr[-min(7, len(arr)):], 1)[0] if len(arr) > 1 else 0,
    }
    
    return np.array(list(features.values())).reshape(1, -1)

def get_feature_names() -> List[str]:
    return ['mean', 'std', 'trend', 'rolling_mean_7', 'rolling_std_7', 'rolling_mean_30',
            'personnel_count', 'season_winter', 'season_summer', 'season_spring', 'season_autumn',
            'max_consumption', 'min_consumption', 'recent_trend']

def generate_synthetic_training_data(n_samples: int = 1000) -> tuple:
    """Generate synthetic training data for initial model training"""
    np.random.seed(42)
    X = []
    y = []
    
    for _ in range(n_samples):
        mean = np.random.uniform(1.0, 5.0)
        std = np.random.uniform(0.1, 1.5)
        trend = np.random.uniform(-0.05, 0.05)
        personnel = np.random.randint(10, 50)
        season = np.random.choice(['WINTER', 'SUMMER', 'SPRING', 'AUTUMN'])
        
        # Generate historical data
        days = np.random.randint(14, 60)
        historical = []
        for i in range(days):
            val = mean + trend * i + np.random.normal(0, std)
            if season == "WINTER":
                val *= 1.2
            elif season == "SUMMER":
                val *= 0.9
            historical.append(max(0, val))
        
        features = extract_features(historical, personnel, season)
        X.append(features.flatten())
        
        # Target: 30-day consumption
        target = np.mean(historical[-7:]) * 30 * (personnel / 25)
        if season == "WINTER":
            target *= 1.2
        y.append(target)
    
    return np.array(X), np.array(y)

def train_model():
    """Train or load the forecasting model"""
    os.makedirs("/app/models", exist_ok=True)
    
    if os.path.exists(MODEL_PATH) and os.path.exists(SCALER_PATH):
        model = joblib.load(MODEL_PATH)
        scaler = joblib.load(SCALER_PATH)
        return model, scaler
    
    # Train new model
    X, y = generate_synthetic_training_data(2000)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    model = GradientBoostingRegressor(
        n_estimators=100,
        learning_rate=0.1,
        max_depth=5,
        random_state=42
    )
    model.fit(X_scaled, y)
    
    joblib.dump(model, MODEL_PATH)
    joblib.dump(scaler, SCALER_PATH)
    
    return model, scaler

def deterministic_forecast(historical: List[float], personnel: int, season: str, 
                          current_stock: int, minimum_stock: int) -> dict:
    """Deterministic fallback forecasting when ML model unavailable"""
    if len(historical) == 0:
        avg_daily = 2.5
    else:
        # Use rolling 7-day average with trend
        recent = historical[-7:] if len(historical) >= 7 else historical
        avg_daily = np.mean(recent)
        if len(historical) > 1:
            trend = np.polyfit(np.arange(len(historical)), historical, 1)[0]
            avg_daily += trend * 15  # Project trend forward
    
    # Seasonal adjustment
    seasonal_factor = {"WINTER": 1.25, "SPRING": 1.05, "SUMMER": 0.95, "AUTUMN": 1.0}.get(season, 1.0)
    avg_daily *= seasonal_factor
    
    # Personnel scaling
    avg_daily *= (personnel / 25.0)
    
    predicted_30 = int(avg_daily * 30)
    shortage_prob = min(100, max(0, (predicted_30 - current_stock) / max(1, predicted_30) * 100))
    
    # Calculate expected shortage date
    if current_stock > 0 and avg_daily > 0:
        days_until_shortage = current_stock / avg_daily
        shortage_date = (datetime.now() + timedelta(days=int(days_until_shortage))).strftime("%Y-%m-%d")
    else:
        shortage_date = None
    
    recommended = max(0, predicted_30 - current_stock + minimum_stock)
    
    # Calculate factor contributions
    factors = {}
    if len(historical) > 1:
        trend = np.polyfit(np.arange(len(historical)), historical, 1)[0]
        if trend > 0.02:
            factors["highConsumptionTrend"] = min(30, abs(trend) * 100)
    if current_stock < minimum_stock * 1.5:
        factors["lowCurrentStock"] = 30 * (1 - current_stock / max(1, minimum_stock * 1.5))
    if personnel > 30:
        factors["personnelDemand"] = min(25, (personnel - 25) * 1.5)
    if season == "WINTER":
        factors["seasonalDemand"] = 20
    
    urgency = "HIGH" if shortage_prob > 70 else "MEDIUM" if shortage_prob > 40 else "LOW"
    
    return {
        "predicted_30": predicted_30,
        "shortage_prob": shortage_prob,
        "confidence": 0.75,
        "shortage_date": shortage_date,
        "recommended": recommended,
        "urgency": urgency,
        "factors": factors
    }

# Initialize model on startup
model, scaler = train_model()

@app.get("/health")
def health():
    return {"status": "healthy", "model_loaded": model is not None}

@app.post("/api/forecast", response_model=InventoryForecastOutput)
def forecast_inventory(input: InventoryForecastInput):
    try:
        # Try ML model first
        features = extract_features(input.historical_consumption, input.personnel_count, input.season)
        features_scaled = scaler.transform(features)
        predicted_30 = max(0, int(model.predict(features_scaled)[0]))
        
        # Calculate shortage probability
        if predicted_30 > 0:
            shortage_prob = min(100, max(0, (predicted_30 - input.current_stock) / predicted_30 * 100))
        else:
            shortage_prob = 0
        
        confidence = 0.85
        ai_mode = "ML"
        
        # Expected shortage date
        if input.current_stock > 0 and predicted_30 > 0:
            daily_rate = predicted_30 / 30.0
            days_left = input.current_stock / daily_rate
            shortage_date = (datetime.now() + timedelta(days=int(days_left))).strftime("%Y-%m-%d")
        else:
            shortage_date = None
        
        recommended = max(0, predicted_30 - input.current_stock + input.minimum_stock)
        
        # Factor contributions
        factors = {}
        if len(input.historical_consumption) > 1:
            trend = np.polyfit(np.arange(len(input.historical_consumption)), input.historical_consumption, 1)[0]
            if trend > 0.02:
                factors["highConsumptionTrend"] = round(min(30, abs(trend) * 100), 1)
        if input.current_stock < input.minimum_stock * 1.5:
            factors["lowCurrentStock"] = round(30 * (1 - input.current_stock / max(1, input.minimum_stock * 1.5)), 1)
        if input.personnel_count > 30:
            factors["personnelDemand"] = round(min(25, (input.personnel_count - 25) * 1.5), 1)
        if input.season == "WINTER":
            factors["seasonalDemand"] = 20
        
        urgency = "HIGH" if shortage_prob > 70 else "MEDIUM" if shortage_prob > 40 else "LOW"
        
    except Exception as e:
        # Fallback to deterministic
        result = deterministic_forecast(
            input.historical_consumption, input.personnel_count, input.season,
            input.current_stock, input.minimum_stock
        )
        predicted_30 = result["predicted_30"]
        shortage_prob = result["shortage_prob"]
        confidence = result["confidence"]
        shortage_date = result["shortage_date"]
        recommended = result["recommended"]
        urgency = result["urgency"]
        factors = result["factors"]
        ai_mode = "RULE_BASED_FALLBACK"
    
    return InventoryForecastOutput(
        item_id=input.item_id,
        predicted_consumption_30_days=predicted_30,
        shortage_probability=round(shortage_prob, 1),
        confidence=round(confidence, 2),
        expected_shortage_date=shortage_date,
        recommended_procurement=recommended,
        urgency=urgency,
        factors=factors,
        ai_mode=ai_mode,
        model_version="1.0.0"
    )
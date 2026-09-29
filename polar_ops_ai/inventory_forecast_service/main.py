from fastapi import FastAPI
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

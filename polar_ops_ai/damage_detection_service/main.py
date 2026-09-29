from fastapi import FastAPI, UploadFile, File
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

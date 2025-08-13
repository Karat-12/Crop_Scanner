from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from io import BytesIO
from PIL import Image
import numpy as np
import tensorflow as tf
import json
import os

app = FastAPI(title="Crop Disease Analyzer")

# Load MLP model
model = tf.keras.models.load_model("plant_disease_mlp.h5")

# Load class names from JSON
with open("class_names.json", "r") as f:
    CLASS_LABELS = json.load(f)

@app.get("/api/crop/test")
async def test_api():
    return {"message": "Crop AI service is running!"}

@app.post("/api/crop/analyze")
async def analyze_crop(file: UploadFile = File(...)):
    try:
        # Read uploaded file
        contents = await file.read()
        img = Image.open(BytesIO(contents)).convert("RGB")

        # Resize to 64x64 for MLP
        img = img.resize((64, 64))
        arr = np.array(img) / 255.0  # normalize

        # Flatten for MLP input
        arr = arr.flatten()[np.newaxis, :]  # shape (1, 64*64*3)

        # Make prediction
        preds = model.predict(arr)
        pred_index = int(np.argmax(preds, axis=1)[0])

        # Safe label lookup
        pred_label = CLASS_LABELS[pred_index] if pred_index < len(CLASS_LABELS) else "Unknown"

        confidence = float(preds[0][pred_index]) * 100

        # Compute simple metrics
        r_mean = float(arr[0][0::3].mean())
        g_mean = float(arr[0][1::3].mean())
        b_mean = float(arr[0][2::3].mean())

        response = {
            "crop": pred_label,
            "health": "Healthy" if "healthy" in pred_label.lower() else "Diseased",
            "nutrition": "Total Diseased" if "healthy" not in pred_label.lower() else "N/A",
            "metrics": {
                "r_mean": round(r_mean, 2),
                "g_mean": round(g_mean, 2),
                "b_mean": round(b_mean, 2)
            },
            "disease_percentage": round(confidence, 2)
        }

        return JSONResponse(content=response)

    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

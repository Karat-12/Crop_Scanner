from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from io import BytesIO
from PIL import Image
import numpy as np
import tensorflow as tf
import json

app = FastAPI(title="Crop Disease Analyzer (No CNN)")

# Load MLP model
model = tf.keras.models.load_model("plant_disease_mlp.h5")

# Load class names
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
        img = img.resize((64, 64))  # MLP input size
        arr = np.array(img) / 255.0
        arr = arr.flatten()[np.newaxis, :]

        # MLP prediction
        preds = model.predict(arr)
        pred_index = int(np.argmax(preds, axis=1)[0])
        pred_prob = float(preds[0][pred_index]) * 100

        # Extract crop and disease
        pred_label = CLASS_LABELS[pred_index]
        if "_" in pred_label:
            parts = pred_label.split("_")
            crop_name = parts[0]
            disease_name = "_".join(parts[1:]) if len(parts) > 1 else "Healthy"
        else:
            crop_name = pred_label
            disease_name = "Healthy"

        # Disease percentage
        disease_percentage = round(pred_prob, 2)
        health_status = "Healthy" if disease_name.lower() in ["healthy", "none"] else "Diseased"

        response = {
            "crop": crop_name,
            "disease": disease_name,
            "health": health_status,
            "disease_percentage": disease_percentage
        }

        return JSONResponse(content=response)

    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=500)

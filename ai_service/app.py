from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from io import BytesIO
from PIL import Image
import numpy as np

app = FastAPI(title="Simple Crop Analyzer")

# Allow all origins (only for development)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/analyze")
async def analyze(file: UploadFile = File(...)):
    """Accepts an image file and returns a simple greenness-based analysis."""
    contents = await file.read()
    try:
        img = Image.open(BytesIO(contents)).convert("RGB")
        arr = np.array(img)

        # Calculate average color values
        r_mean = float(arr[:, :, 0].mean())
        g_mean = float(arr[:, :, 1].mean())
        b_mean = float(arr[:, :, 2].mean())

        # Simple heuristic for plant health
        green_ratio = g_mean / (r_mean + b_mean + 1e-6)
        if green_ratio > 1.1 and g_mean > 80:
            health = "Healthy Vegetation"
            nutrition = "Likely sufficient nitrogen"
        elif green_ratio > 0.95:
            health = "Moderately healthy"
            nutrition = "Possible mild nitrogen deficiency"
        else:
            health = "Poor Vegetation / Dry"
            nutrition = "Likely nitrogen deficient"

        return JSONResponse(content={
            "crop": "Unknown",
            "health": health,
            "nutrition": nutrition,
            "metrics": {
                "r_mean": r_mean,
                "g_mean": g_mean,
                "b_mean": b_mean,
                "green_ratio": green_ratio
            }
        })
    except Exception as e:
        return JSONResponse(status_code=400, content={"error": str(e)})
@app.get("/test")
async def test():
    return {"status": "AI service is running!"}

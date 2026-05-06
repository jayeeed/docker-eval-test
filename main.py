from fastapi import FastAPI

app = FastAPI(title="Minimal FastAPI App")

@app.get("/health")
async def health_check():
    return {"status": "ok"}

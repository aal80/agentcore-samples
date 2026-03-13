from fastapi import FastAPI, Request
import uvicorn

app = FastAPI()

@app.post("/invocations")
async def invoke_agent(request: Request):
    body = await request.json()
    return {
        "msg":"response!",
        "received_payload": body,
    }

@app.get("/ping")
async def ping():
    return {"status":"healthy"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)

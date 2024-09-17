from typing import Union

from device_assistant.chat_models import ChatRequest
from fastapi import FastAPI

from chat import chat

app = FastAPI()




@app.get("/")
def read_root():
    return "Welcome to the FastAPI chat application"

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.post("/chat")
def post_chat(chat_request: ChatRequest):
    result = chat(chat_request)
    return result

if __name__ == "__main__" :
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
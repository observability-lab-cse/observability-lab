from typing import Union

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class ChatRequest(BaseModel):
    q: str


@app.get("/")
def read_root():
    return "Welcome to the FastAPI chat application"

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.post("/chat")
def post_chat(chat_request: ChatRequest):
    return {"q": chat_request.q}
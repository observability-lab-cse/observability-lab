from pydantic import BaseModel
class ChatRequest(BaseModel):
    q: str
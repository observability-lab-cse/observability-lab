import os
import requests
from device_assistant.chat_models import ChatRequest

# Configuration
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY') 
OPENAI_ENDPOINT = os.getenv('OPENAI_ENDPOINT')
Prompt = "You are an AI assistant that helps people find information."

def chat(chat_request: ChatRequest):
    headers = {
        "Content-Type": "application/json",
        "api-key": OPENAI_API_KEY,
    }

    # Payload for the request
    payload = {
      "messages": [
        {
          "role": "system",
          "content": [
            {
              "type": "text",
              "text": Prompt
            }
          ]
        },
        {
          "role": "user",
          "content": [
            {
              "type": "text",
              "text": chat_request.question
            }
          ]
        }
      ],
      "temperature": 0.7,
      "top_p": 0.95,
      "max_tokens": 800
    }

    # Send request
    try:
        response = requests.post(f"{OPENAI_ENDPOINT}/chat/completions?api-version=2024-02-15-preview", headers=headers, json=payload)
        response.raise_for_status()  # Will raise an HTTPError if the HTTP request returned an unsuccessful status code
    except requests.RequestException as e:
        raise SystemExit(f"Failed to make the request. Error: {e}")

    # Handle the response as needed (e.g., print or process)
    return response.json()
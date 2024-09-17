import os
import requests
from device_assistant.chat_models import ChatRequest

# Configuration
API_KEY = os.getenv('API_KEY') #"5e94e2d64ed6465ba67b5b462889f281"
ENDPOINT = os.getenv('ENDPOINT') #"https://azoi-cloudguru-swed.openai.azure.com/openai/deployments/osama-gpt4o/chat/completions?api-version=2024-02-15-preview"
Prompt = "You are an AI assistant that helps people find information."

def chat(chat_request: ChatRequest):
    headers = {
        "Content-Type": "application/json",
        "api-key": API_KEY,
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
          "text": chat_request.q
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
        response = requests.post(ENDPOINT, headers=headers, json=payload)
        response.raise_for_status()  # Will raise an HTTPError if the HTTP request returned an unsuccessful status code
    except requests.RequestException as e:
        raise SystemExit(f"Failed to make the request. Error: {e}")

    # Handle the response as needed (e.g., print or process)
    return response.json()
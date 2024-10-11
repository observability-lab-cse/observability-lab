# Device Assistant with OpenAI Model

This project integrates a device assistant powered by OpenAI. To run the assistant, you will need to set up your OpenAI API credentials.

If you would like to run this assistant with your own OpenAI model, In the root directory of the project, there is a `.env.sample` file that contains environment variables required to run the assistant.

Rename the `.env.sample` file to `.env`:

```txt
OPENAI_API_KEY=<your-openai-api-key>
OPENAI_API_ENDPOINT=<your-openai-api-endpoint>
```

Running the Assistant
Once you've set up your `.env` file, you can run the assistant using the following command:

```sh
cd sample-application/device-assistant/
poetry install
poetry run python main.py
```

# Use the official Alpine-based Python image
FROM python:3.11-alpine

# Set the working directory inside the container
WORKDIR /app

# Install Poetry
RUN pip install --no-cache-dir poetry
RUN poetry config virtualenvs.create false

# Copy the pyproject.toml and poetry.lock files and install dependencies
COPY pyproject.toml poetry.lock ./
RUN poetry install --no-root --no-dev

# Copy the application code into the container
COPY . .

# Expose the necessary port for FastAPI
EXPOSE 8000

# Set the command to run main.py using uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
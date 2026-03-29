FROM python:3.12-slim

# Create a non-root user for security
RUN useradd -m appuser
USER appuser
WORKDIR /home/appuser

# Install dependencies first
COPY --chown=appuser:appuser application-test/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY --chown=appuser:appuser application-test/ .

EXPOSE 8080

# Execute the Flask app
CMD ["python", "main.py"]

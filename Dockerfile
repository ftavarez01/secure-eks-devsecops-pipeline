# 1. Use a slim image to reduce the attack surface
FROM python:3.12-slim

# 2. SECURITY PATCH: Update the OS to fix CVEs (like the systemd one) -> CVE-2026-29111 if OS not upgraded.
# We run this as root before switching to the limited user
USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 3. Create a non-root user securely (UID 1000)
RUN useradd -m -u 1000 appuser

# 4. Set the working directory
WORKDIR /home/appuser

# 5. Install dependencies (Caching Layer)
# We copy only requirements first to optimize build time
COPY --chown=appuser:appuser application-test/requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 6. Copy the application code with correct ownership
COPY --chown=appuser:appuser application-test/ .

# 7. Switch to the limited user for execution
USER appuser

# 8. Recommended Python Environment Variables for Docker
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

EXPOSE 8080

# Execute the Flask app
CMD ["python", "main.py"]

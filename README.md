# Branch Loan API

A containerized Flask API for managing microloans, featuring a complete DevOps pipeline with CI/CD, monitoring, and multi-environment support.

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Python](https://img.shields.io/badge/python-3.11-blue)
![Docker](https://img.shields.io/badge/docker-ready-blue)




## Architecture

Traffic flows through Nginx (SSL termination) to the Flask API, which connects to PostgreSQL. Prometheus scrapes metrics from the API, visualized in Grafana.

![Architecture Diagram](architecture_diagram.png)


## Prerequisites

-   **Docker** and **Docker Compose**
-   **Make** (Optional)
    -   Ubuntu/Debian: `sudo apt-get install make`
    -   Mac: `brew install make`
    -   Windows: `choco install make`

## Setup & Usage

1.  **DNS Setup**: Map the local domain.
    ```bash
    echo "127.0.0.1 branchloans.com" | sudo tee -a /etc/hosts
    ```

2.  **Start Application**:
    You can use `make` for simplicity, or standard `docker-compose` commands.

    | Action | Make Command | Docker Command |
    |---|---|---|
    | **Start (Dev)** | `make up` | `docker-compose up -d --build` |
    | **Stop** | `make down` | `docker-compose down` |
    | **View Logs** | `make logs` | `docker-compose logs -f` |
    | **Check Status** | `make ps` | `docker-compose ps` |

3.  **Verify**:
    -   API: `https://branchloans.com/health`
    -   Metrics: `https://branchloans.com/metrics`

## Environments

| Environment | Config File | Logging | Restart Policy |
|---|---|---|---|
| **Development** | `docker-compose.override.yml` | DEBUG | No |
| **Staging** | `docker-compose.staging.yml` | INFO | On-Failure |
| **Production** | `docker-compose.prod.yml` | INFO (JSON) | Always |

To switch environments:
```bash
# Staging
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d --build

# Production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```


## Environment Variables

The application is configured via environment variables.

| Variable | Description | Default |
|---|---|---|
| `FLASK_ENV` | Sets Flask mode (development/production) | `production` |
| `LOG_LEVEL` | Logging verbosity (DEBUG, INFO, WARNING) | `INFO` |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://...` |
| `LOG_FORMAT` | Log format: `text` or `json` | `text` |

## Design Decisions & Trade-offs

### 1. Nginx for SSL Termination
-   **Decision**: Use Nginx as a reverse proxy to handle HTTPS.
-   **Why**: Decouples security from application logic and improves performance.
-   **Trade-off**: Adds a slight complexity to the Docker Compose setup compared to running SSL directly in Flask.

### 2. Multi-Stage Docker Builds
-   **Decision**: Use multi-stage builds for the API image.
-   **Why**: Reduces final image size by excluding build dependencies (compilers, headers).
-   **Trade-off**: Slightly longer build times during the first run.

### 3. Gunicorn vs. Flask Server
-   **Decision**: Use Gunicorn for production.
-   **Why**: The default Flask server is single-threaded and not suitable for production traffic.
-   **Trade-off**: Requires an extra dependency (`gunicorn`) and configuration.

## Monitoring

-   **Prometheus**: [http://localhost:9091](http://localhost:9091)
-   **Grafana**: [http://localhost:3000](http://localhost:3000) (Default: `admin`/`admin`)

## CI/CD Pipeline

Before Starting the CI/CD add the Docker Username and Password of your Docker Hub in Push stage

The GitHub Actions workflow (`.github/workflows/ci-cd.yml`) handles:
1.  **Test**: Unit tests and linting.
2.  **Secret Scan**: Scans for hardcoded secrets using **Gitleaks**.
3.  **Build**: Multi-stage Docker build.
4.  **Vuln Scan**: Security vulnerability scanning with **Trivy**.
5.  **Push**: Uploads to Docker Hub (main branch only).

## Troubleshooting

-   **502 Bad Gateway**: The API container is likely crashing. Run `docker-compose logs api` to debug.
-   **Port Conflicts**: Ensure ports 80, 443, and 5432 are free.
-   **No Metrics**: Prometheus requires traffic to generate data. Run `curl -k https://branchloans.com/health` a few times.
-   **Make not found**: If you cannot install `make`, simply use the Docker commands listed in the "Setup & Usage" section.

---

## Project Status

### Core Requirements
-   **Containerization**: Dockerized API & DB with Nginx for SSL termination.
-   **Multi-Environment**: Dev (Hot-reload), Staging, and Production (Secure & Optimized).
-   **CI/CD Pipeline**: Automated Build, Test, and Security Scans (Trivy & Gitleaks).
-   **Documentation**: Clear setup guides, architecture diagrams, and troubleshooting.

### Bonus & "Extra Mile" Features
-   **Observability**: Real-time monitoring with **Prometheus & Grafana**.
-   **Security**: Added **Gitleaks** to catch secrets before they hit the repo.
-   **Production Logging**: Structured JSON logs for better debugging.
-   **Resilience**: Robust `/health` checks that actually verify DB connectivity.
-   **Developer Experience**: Added a `Makefile` to save time on typing commands.

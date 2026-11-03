# Production DevSecOps Incident Triage & Automated Security Gating Lab

[![Container Release & Trivy Gating](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/container-publish.yml/badge.svg)](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/container-publish.yml)
[![TruffleHog Secret Scan](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/secret-scan.yml/badge.svg)](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/secret-scan.yml)

A reference implementation demonstrating shift-left container vulnerability management, automated commit-level secret detection, least-privilege CI/CD authorization scoping, and forensic Git history remediation for leaked cloud credentials.

---

## Architecture & Security Posture

```text
                                  +------------------------------------+
                                  |        Developer Workstation       |
                                  |   (Local Pre-commit TruffleHog)    |
                                  +-----------------+------------------+
                                                    |  git push
                                                    v
+--------------------------------------------------------------------------------------------------+
| GitHub CI/CD Environment (Harden-Runner Egress Audit)                                            |
|                                                                                                  |
|   +------------------------------------+           +-----------------------------------------+   |
|   |   Workflow: Secret Scanning        |           |   Workflow: Container Build & Release   |   |
|   |   - TruffleHog OSS Engine          |           |   - Multi-stage Docker Build (Node.js)  |   |
|   |   - Full commit history traversal  |           |   - Non-root user execution (appuser)   |   |
|   |   - Active secret verification     |           |   - Dual-layer Aqua Trivy scan          |   |
|   +------------------------------------+           +--------------------+--------------------+   |
|                                                                         |                        |
|                                                                         v                        |
|                                                    +--------------------+--------------------+   |
|                                                    | GHCR Registry Push Authorization Gating |   |
|                                                    | (Scoped Token: packages: write)         |   |
+----------------------------------------------------+--------------------+--------------------+---+
                                                                          |
                                                                          v
                                                     +--------------------+--------------------+
                                                     |    GitHub Container Registry (GHCR)     |
                                                     |    ghcr.io/.../devsecops-lab:latest     |
                                                     +-----------------------------------------+
```


### Core Security Controls
* **Hardened Multi-Stage Container (Dockerfile): Builds runtime artifacts using npm ci --omit=dev and executes as an unprivileged user (appuser:appgroup) to prevent container breakout vulnerabilities. Includes native /healthz polling.

* **Dual-Layer Vulnerability Scanning (Aqua Security Trivy): Scans base Alpine OS packages and application dependencies directly in the pipeline, reporting HIGH and CRITICAL vulnerabilities to the runner console in structured table format.

* **Automated Secret Detection (TruffleHog OSS): Evaluates full Git commit graphs (fetch-depth: 0) across PRs and branches to block unverified/verified secrets before release.

* **Least-Privilege Token Permissions: Workflows explicitly restrict ${{ secrets.GITHUB_TOKEN }} to the minimum scopes required: contents: read for checkout, packages: write for GHCR publishing, and security-events: write for workflow telemetry

---

## Local Development & Testing

### Running the Microservice Locally
```bash
# Build the hardened image
docker build -t devsecops-lab:local .

# Run container as non-root user
docker run -d --name devsecops-lab -p 3000:3000 devsecops-lab:local

# Verify health endpoint
curl http://localhost:3000/healthz

trivy image --severity HIGH,CRITICAL devsecops-lab:local

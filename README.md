# DevSecOps Incident Triage & Security Automation Lab

[![Container Release & Trivy Scan](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/container-publish.yml/badge.svg)](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/container-publish.yml)

[![TruffleHog Secret Scan](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/secret-scan.yml/badge.svg)](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/secret-scan.yml)

A hands-on DevSecOps lab demonstrating container security scanning, automated secret detection, GitHub Actions permissions, GHCR publishing, and Git history remediation through controlled security simulations.

---

## Architecture & Security Controls

```text
                  +--------------------------------------+
                  |        Developer Workstation         |
                  |     Local TruffleHog Secret Scan     |
                  +------------------+-------------------+
                                     |
                                  git push
                                     |
                                     v
+--------------------------------------------------------------------+
|                  GitHub Actions CI/CD Environment                  |
|                    Harden-Runner Egress Audit                      |
|                                                                    |
|  +-----------------------------+  +-------------------------------+ |
|  | Secret Scanning Workflow    |  | Container Build & Release     | |
|  |                             |  |                               | |
|  | - TruffleHog OSS            |  | - Multi-stage Docker build    | |
|  | - Full Git history          |  | - Non-root execution         | |
|  | - Verified secret checks    |  | - Trivy OS and library scan  | |
|  +-----------------------------+  +---------------+---------------+ |
|                                                   |                |
|                                                   v                |
|                                  +-------------------------------+ |
|                                  | GHCR Authentication & Publish | |
|                                  | GitHub Token: packages: write | |
|                                  +---------------+---------------+ |
+--------------------------------------------------------------------+
                                                    |
                                                    v
                                  +-------------------------------+
                                  | GitHub Container Registry     |
                                  | GHCR                          |
                                  +-------------------------------+
```

### Core Security Controls

**1. Container Security**

The Dockerfile uses a multi-stage build and runs the application as a non-root user. Production dependencies are installed using `npm ci --omit=dev`, and the application exposes a `/healthz` endpoint for health checks.

**2. Vulnerability Scanning – Trivy**

Aqua Security Trivy scans the container image for operating system and application library vulnerabilities. The workflow reports HIGH and CRITICAL findings in table format.

The current workflow is configured with `exit-code: '0'`, so findings are reported without automatically failing the pipeline.

**3. Automated Secret Detection – TruffleHog OSS**

TruffleHog is integrated into GitHub Actions to scan the repository using `fetch-depth: 0`, which makes the full Git history available to the workflow.

The scan uses `--only-verified` to focus on secrets that TruffleHog can verify.

**4. GitHub Actions Permissions**

The container publishing workflow uses explicit permissions, including:

- `contents: read` for repository checkout.
- `packages: write` for publishing images to GHCR.
- `security-events: write` as an explicitly granted workflow permission.

**5. Runner Security Monitoring**

StepSecurity Harden-Runner runs in audit mode to monitor outbound network activity during workflow execution.

---

## Incident Triage & Remediation

This project includes two controlled security exercises.

### 1. GHCR 403 Forbidden – Authorization Triage

Simulated and investigated a container publishing failure caused by insufficient GitHub package permissions.

The original workflow used `packages: read`, which did not allow image publishing. The permission was changed to `packages: write`, and package access settings were reviewed.

[Read the GHCR Authorization Triage Runbook](runbook/GHCR%20403%20Forbidden%20Authorization%20Triage.md)

### 2. Azure Storage Credential Exposure & Git History Remediation

Simulated an Azure Storage credential exposure using a randomly generated practice credential.

The exercise covered secret detection, Git history cleanup with Git Filter-Repo, `.gitignore` configuration, and local and automated TruffleHog scanning.

No real production credentials were exposed.

[Read the Azure Storage Credential Remediation Runbook](runbook/Cloud%20Storage%20Credential%20Leak%20%26%20Git%20History%20Remediation.md)

---

## Local Development & Testing

### Build the Docker Image

```bash
docker build -t devsecops-lab:local .
```

### Run the Container

```bash
docker run -d --name devsecops-lab -p 3000:3000 devsecops-lab:local
```

### Verify the Health Endpoint

```bash
curl http://localhost:3000/healthz
```

### Scan the Container Image

```bash
trivy image --severity HIGH,CRITICAL devsecops-lab:local
```

---

## Tools & Technologies

- Microsoft Azure Storage
- Azure CLI
- Docker
- Git and GitHub
- GitHub Actions
- GitHub Container Registry (GHCR)
- Trivy
- TruffleHog OSS
- StepSecurity Harden-Runner
- Git Filter-Repo
- YAML

---

## Project Repository

[DevSecOps Incident Triage Lab – GitHub](https://github.com/temade91/Devsecops-Incident-Triage-Lab)

**Project Note:** Independently developed and implemented as a hands-on security simulation covering container scanning, secret detection, CI/CD permissions, and incident remediation.

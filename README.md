# DevSecOps Incident Triage & Security Automation Lab

[![Container Release & Trivy Scan](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/container-publish.yml/badge.svg)](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/container-publish.yml)

[![TruffleHog Secret Scan](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/secret-scan.yml/badge.svg)](https://github.com/temade91/Devsecops-Incident-Triage-Lab/actions/workflows/secret-scan.yml)

A hands-on DevSecOps lab demonstrating container security scanning, automated secret detection, CI/CD authorization troubleshooting, GHCR image publishing, and Git history remediation through controlled security simulations.

---

## 1. Architecture & Security Controls

```text
                    +--------------------------------------+
                    |        Developer Workstation         |
                    |       Local TruffleHog Scan          |
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
|  | - Full Git history          |  | - Node.js 20 Alpine 3.19      | |
|  | - Verified secret checks    |  | - Non-root execution         | |
|  |                             |  | - Trivy OS and library scan  | |
|  +-----------------------------+  +---------------+---------------+ |
|                                                   |                |
|                                                   v                |
|                                  +-------------------------------+ |
|                                  | GHCR Authentication & Publish | |
|                                  | GitHub Token: packages: write | |
|                                  +---------------+---------------+ |
+--------------------------------------------------|-----------------+
                                                   |
                                                   v
                                  +-------------------------------+
                                  | GitHub Container Registry     |
                                  | GHCR                          |
                                  +-------------------------------+
```

### Core Security Controls

**Container Security – Docker**

The Dockerfile uses a multi-stage build based on Node.js 20 Alpine 3.19. Production dependencies are installed using `npm ci --omit=dev`, followed by npm cache cleanup.

The runtime container uses a dedicated non-root account (`appuser:appgroup`). Application files are assigned to this account, and a Docker health check monitors the `/healthz` endpoint.

**Vulnerability Scanning – Trivy**

Aqua Security Trivy scans the container image for operating system and application library vulnerabilities.

The GitHub Actions workflow reports HIGH and CRITICAL findings in table format. Its current configuration uses `exit-code: '0'`, meaning findings are reported without automatically failing the workflow or blocking image publishing.

**Automated Secret Detection – TruffleHog OSS**

TruffleHog is integrated into GitHub Actions to scan the repository using `fetch-depth: 0`, making the full Git history available to the scanner.

The workflow uses `--only-verified` to focus on secrets that TruffleHog can verify.

**Runner Security Monitoring – Harden-Runner**

StepSecurity Harden-Runner runs in audit mode to monitor outbound network activity during GitHub Actions workflow execution.

**GitHub Actions Permissions**

The container publishing workflow uses explicit permissions:

- `contents: read` for repository checkout.
- `packages: write` for publishing container images to GHCR.
- `security-events: write` as an explicitly granted workflow permission.

---

## 2. Incident Triage & Remediation

This project includes two controlled security exercises demonstrating incident investigation, remediation, and validation.

### Incident 1: GHCR 403 Forbidden – Authorization Triage

**Service:** GitHub Container Registry (GHCR)

**Problem:** A Docker image built successfully, but publishing failed with a `403 Forbidden` authorization error.

The error message was:

```text
denied: installation not allowed to Create organization package
```

**Root Cause:**

The original GitHub Actions workflow used `packages: read`, which did not provide the required permission to publish container images.

**Remediation:**

- Updated the workflow permission from `packages: read` to `packages: write`.
- Reviewed GitHub package access settings.
- Reran the GitHub Actions workflow.
- Confirmed successful image publishing to GHCR.

[Read the GHCR 403 Authorization Triage Runbook](runbook/GHCR%20403%20Forbidden%20Authorization%20Triage.md)

### Incident 2: Azure Storage Credential Exposure & Git History Remediation

**Service:** Microsoft Azure Storage

**Severity:** Medium

**Status:** Resolved – Security Simulation

**Problem:**

A randomly generated practice credential was committed in an environment file (`azure-storage.env`) to simulate accidental credential exposure.

**Remediation Exercise:**

- Reviewed the simulated credential exposure.
- Used Git Filter-Repo to remove the sensitive file from Git history.
- Added sensitive environment files to `.gitignore`.
- Reviewed local TruffleHog scanning results.
- Integrated TruffleHog into GitHub Actions for automated repository scanning.

No real production credentials were exposed.

[Read the Azure Storage Credential Exposure & Git History Remediation Runbook](runbook/Cloud%20Storage%20Credential%20Leak%20%26%20Git%20History%20Remediation.md)

---

## 3. Local Development & Testing

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

### Scan the Container Image with Trivy

```bash
trivy image --severity HIGH,CRITICAL devsecops-lab:local
```

### Run a Local TruffleHog Scan

```bash
trufflehog filesystem . --only-verified
```

---

## 4. GitHub Actions Workflows

This repository contains two automated workflows.

| Workflow | Purpose | Trigger |
|---|---|---|
| `secret-scan.yml` | Scans repository history for verified secrets using TruffleHog | Push, pull request to main, manual |
| `container-publish.yml` | Builds the Docker image, scans it with Trivy, and publishes it to GHCR | Push to main, manual |

Both workflows use StepSecurity Harden-Runner in audit mode.

The container workflow reports Trivy findings and proceeds with publishing according to its current configuration. The secret-scanning workflow runs independently.

---

## 5. Tools & Technologies

- Microsoft Azure Storage
- Azure CLI
- Docker
- Node.js 20
- Git and GitHub
- GitHub Actions
- GitHub Container Registry (GHCR)
- Trivy
- TruffleHog OSS
- StepSecurity Harden-Runner
- Git Filter-Repo
- YAML

---

## 6. Key Learning Outcomes

Through these exercises, I demonstrated practical experience with:

- Investigating CI/CD authorization failures.
- Configuring GitHub Actions token permissions.
- Building multi-stage Docker images.
- Running containers as non-root users.
- Scanning container images for vulnerabilities.
- Detecting verified secrets in Git repositories.
- Removing sensitive files from Git history.
- Applying preventive controls to reduce accidental credential exposure.
- Monitoring GitHub Actions runner network activity.

---

## 7. Project Repository

**GitHub:** [DevSecOps Incident Triage Lab](https://github.com/temade91/Devsecops-Incident-Triage-Lab)

**Project Note:** Independently developed and implemented as a hands-on DevSecOps security simulation covering container security, secret detection, CI/CD authorization troubleshooting, and incident remediation.

Runbook 1: GHCR 403 Forbidden Authorization Triage
1. Incident Metadata
Classification: CI/CD Deployment Pipeline / Package Registry Authorization Failure

Severity: High (Blocks automated image publishing to GHCR)

Affected Pipeline: .github/workflows/container-publish.yml

Trigger / Error Signature:

Plaintext
ERROR: failed to solve: failed to push ghcr.io/temade91/devsecops-incident-triage-lab:latest: 
denied: installation not allowed to Create organization package (or HTTP 403 Forbidden)
2. Root Cause Analysis (RCA)
GitHub Actions automatically provisions an ephemeral ${{ secrets.GITHUB_TOKEN }} per workflow execution. By default, workflow tokens strictly adhere to least-privilege scoping. The release workflow succeeded locally during the Docker build and Aqua Trivy vulnerability scan phases, but failed during the registry push phase.

The workflow token permissions block in .github/workflows/container-publish.yml was misconfigured with:

YAML
permissions:
  contents: read
  packages: read      # <--- ROOT CAUSE: Lacks permission to create/push new package artifacts
  security-events: write
Because the token was restricted to read-only package access, Docker Buildx received an HTTP 403 Forbidden response when attempting to authenticate and push image layers to ghcr.io.

3. Triage & Remediation Procedure
Step 3.1: Elevate Workflow Scope in YAML
Update .github/workflows/container-publish.yml to elevate the packages scope to write:

YAML
permissions:
  contents: read
  packages: write     # <--- Elevated to permit publishing to GitHub Container Registry
  security-events: write
Step 3.2: Verify Repository Workflow Permissions
Go to your repository on GitHub.

Navigate to Settings > Actions > General.

Under Workflow permissions, ensure Read and write permissions is selected and saved.

Step 3.3: Pipeline Verification
Re-run the container release workflow or push a new commit to main.

Confirm that all stages (Harden Runner, Build, Trivy Scan, and Build & Push) complete with green checkmarks.

Verify that the image package is listed under your profile or repository at [https://github.com/temade91?tab=packages](https://github.com/temade91?tab=packages).
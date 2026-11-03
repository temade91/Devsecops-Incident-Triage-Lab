# GHCR 403 Forbidden – Authorization Triage

## 1. Incident Overview

- **Project:** DevSecOps Incident Triage Lab
- **Service:** GitHub Container Registry (GHCR)
- **CI/CD:** GitHub Actions
- **Severity:** Medium
- **Status:** Resolved

### Summary

During my DevSecOps project, I encountered a `403 Forbidden` error while publishing a Docker image to GitHub Container Registry.

The Docker image built successfully, but the push operation failed due to insufficient package permissions and package creation restrictions.

## 2. Error Identification

**Error message:**

```text
denied: installation not allowed to Create organization package
```

**Impact:**
- Docker image publishing failed.
- GitHub Actions workflow ended unsuccessfully.
- The container image was not published.

### Screenshot 1: Initial Pipeline Failure
<img width="1909" height="584" alt="image" src="https://github.com/user-attachments/assets/8160bb1a-67ee-4e12-addf-f74b6ee1e5a4" />


_Insert screenshot of the failed GHCR image push here._

## 3. Root Cause Analysis

The workflow had the following permissions:

```yaml
permissions:
  contents: read
  packages: read
  security-events: write
```

The `packages: read` permission did not allow the workflow to publish Docker images.

The package access configuration also needed to allow the workflow to create and publish the package.

### Screenshot 2: Original Workflow Configuration

_Insert screenshot showing the original workflow permissions here._

## 4. Remediation

I updated the workflow permissions:

```yaml
permissions:
  contents: read
  packages: write
  security-events: write
```

I also reviewed the GitHub package access settings to ensure the workflow could publish the container image.

`security-events: write` is only needed if the workflow uploads security findings to GitHub Code Scanning.

## 5. Validation and Result

After applying the changes, I reran the GitHub Actions workflow.

**Validation performed:**
- Confirmed `packages: write` permission.
- Reviewed GHCR authentication.
- Successfully rebuilt and pushed the Docker image.
- Verified the published image in GHCR.

<badge color="success">Resolved</badge>

### Screenshot 3: Successful Pipeline Execution

_Insert screenshot of the successful GitHub Actions run or published GHCR package here._

## 6. Lessons Learned

- Authentication and authorization are different.
- Docker image publishing requires appropriate package write permissions.
- GitHub Actions tokens should follow the principle of least privilege.
- Repository and organization package access settings can affect publishing.
- Pipeline logs are essential for troubleshooting CI/CD failures.

## 7. Tools and Technologies

- GitHub Actions
- GitHub Container Registry
- Docker
- Git and GitHub
- YAML
- GitHub Token Permissions

## 8. Project Repository

[DevSecOps Incident Triage Lab](https://github.com/temade91/Devsecops-Incident-Triage-Lab)

**Author:** Independently developed and implemented by me.

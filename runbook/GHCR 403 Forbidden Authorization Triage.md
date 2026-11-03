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
<img width="1898" height="774" alt="image" src="https://github.com/user-attachments/assets/4d691792-4bac-4214-a61f-d438a7e3c9bf" />


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

<img width="1890" height="602" alt="image" src="https://github.com/user-attachments/assets/602b50a6-19d5-492b-b963-4c7b9939216a" />


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

<img width="1896" height="952" alt="image" src="https://github.com/user-attachments/assets/6cf841ea-c28a-452c-8516-4cd9a3c816b1" />

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

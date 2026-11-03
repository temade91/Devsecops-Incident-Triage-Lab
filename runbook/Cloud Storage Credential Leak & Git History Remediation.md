# Runbook 02: Azure Storage Credential Exposure & Git History Remediation

**Project:** DevSecOps Incident Triage Lab  
**Service:** Azure Storage  
**Severity:** Medium  
**Status:** Resolved – Security Simulation

## 1. Incident Overview

As part of my DevSecOps project, I simulated an Azure Storage credential exposure by committing a randomly generated practice credential in an environment file.

The exercise demonstrates secret detection, Git history cleanup, and preventive security controls.

**Note:** This was a controlled simulation. No real production credentials were exposed.

## 2. Root Cause

A sensitive environment file (`azure-storage.env`) was committed without being excluded from Git tracking.

This demonstrated the risk of storing credentials in source control.

## 3. Remediation

For a real credential exposure, the affected Azure Storage key should be rotated:

```bash
az storage account keys renew \
  --resource-group <resource-group> \
  --account-name <storage-account> \
  --key primary
```

Remove the sensitive file from Git history:

```bash
git-filter-repo \
  --path azure-storage.env \
  --invert-paths
```

Add sensitive files to `.gitignore`:

```gitignore
.env
*.env
azure-storage.env
```

## 4. Secret Scanning & Security Controls

**Local Scanning – TruffleHog OSS**

Used locally to detect potential secrets and sensitive information before committing changes to the repository.

**Automated Scanning – GitHub Actions**

Integrated TruffleHog OSS into the CI/CD workflow to scan repository commit history using `fetch-depth: 0` and identify potential exposed credentials.

These controls support early detection and help reduce accidental secret exposure.

screenshot of local TruffleHog scan
<img width="1672" height="941" alt="image" src="https://github.com/user-attachments/assets/3116032d-8ec9-46d3-a0cf-60d323416f91" />

screenshot of successful GitHub Actions secret scan
<img width="1845" height="949" alt="image" src="https://github.com/user-attachments/assets/8824dc13-45b9-4306-9137-04128390607c" />


## 5. Validation

- Reviewed Git history after cleanup.
- Confirmed sensitive environment files are excluded from future commits.
- Reviewed local TruffleHog scanning results.
- Verified the automated secret-scanning workflow.

<img width="1887" height="883" alt="image" src="https://github.com/user-attachments/assets/92c63160-0b17-46e9-9206-f2e4420579c9" />


## 6. Tools & Technologies

- Microsoft Azure Storage
- Azure CLI
- Git and GitHub
- Git Filter-Repo
- TruffleHog OSS
- GitHub Actions

## 7. Project Repository

**GitHub:** https://github.com/temade91/Devsecops-Incident-Triage-Lab

**Project Note:** Independently developed security simulation demonstrating secret detection, credential exposure remediation, Git history cleanup, and automated security controls.

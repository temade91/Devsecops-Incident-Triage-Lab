Cloud Storage Credential Leak & Git History Remediation
1. Incident Metadata
Classification: Secret Exposure / Compromised Cloud Credentials

Severity: Critical (High risk of unauthorized cloud resource access and lateral movement)

Leaked Secret Artifact: azure-storage.env (Azure Storage Account connection string)

Status: Committed to historical Git commits; conventional deletion (git rm) does not remove keys from the .git packfile tree.

2. Forensic Discovery & Blast Radius Assessment
Confirm the presence and historical depth of the leaked key across all refs:

Bash
git grep "prodstordevsecops" $(git rev-list --all)
Output confirms the secret is permanently captured in historical commit objects and exposed to anyone with clone access.

3. Emergency Remediation Protocol
Step 3.1: Cloud Provider Invalidation & Key Rotation (First Priority)
Never attempt Git history remediation before rotating the credential. Treat the secret as actively compromised and revoke it immediately:

Bash
az storage account keys renew \
  --resource-group rg-production \
  --account-name prodstordevsecops \
  --key primary
Step 3.2: History Scrubbing via git-filter-repo
Use git-filter-repo to expunge the file and its references across all branches, tags, and commits:

Bash
# 1. Install tool
sudo apt-get update && sudo apt-get install -y git-filter-repo

# 2. Scrub target file from all Git objects
git-filter-repo --path azure-storage.env --invert-paths --force
Step 3.3: Verification of Eradication
Confirm the secret no longer exists in any commit object:

Bash
git grep "prodstordevsecops" $(git rev-list --all)
Expected result: Zero output. This confirms the secret has been expunged from the entire Git object database.

Step 3.4: Synchronize Sanitized History Upstream
Re-attach the remote origin and push the rewritten commit graph using --force-with-lease:

Bash
git remote add origin https://github.com/temade91/Devsecops-Incident-Triage-Lab.git
git fetch origin main
git push --force-with-lease origin main
4. Preventative Guardrails (Shift-Left Controls)
Workstation Pre-Commit Hook
Prevent unverified secrets from leaving the developer workstation:

Bash
cat << 'HOOK' > .git/hooks/pre-commit
#!/bin/sh
trufflehog git file://. --since-commit HEAD --fail
HOOK
chmod +x .git/hooks/pre-commit
Automated CI Secret Scanning
The .github/workflows/secret-scan.yml pipeline runs on every pull request and push to main with fetch-depth: 0 and --only-verified, blocking merges containing active keys.
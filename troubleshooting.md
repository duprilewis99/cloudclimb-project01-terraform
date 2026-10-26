# Week 2 - Troubleshooting Documentation

## SSH Connectivity Troubleshooting

### Symptom

After intentionally modifying the SSH security group, I was no longer able to connect to the EC2 instance using SSH. The connection attempt timed out on port 22.

### What I Checked

I checked the SSH security group configuration in Terraform and compared the allowed source IP address with my current public IP address.

The SSH security group was configured to allow TCP port 22 from:

`66.205.174.118/32`

My actual public IP address was:

`66.205.174.117`

I also confirmed that the EC2 instance was still running and that the instance had a public IP address.

### Root Cause

The SSH security group was allowing SSH connections only from `66.205.174.118/32`, while my computer's actual public IP address was `66.205.174.117`.

Because the source IP did not match the security group's inbound rule, AWS blocked the SSH connection.

### Fix

I changed the SSH security group configuration in `main.tf` back to:

`66.205.174.117/32`

I then ran:

```bash
terraform plan
```

Terraform detected an in-place security group change:

`Plan: 0 to add, 1 to change, 0 to destroy.`

I applied the change with:

```bash
terraform apply
```

Terraform successfully updated the security group.

### Verification

After applying the corrected configuration, the SSH security group was configured to allow TCP port 22 from my current public IP address.

The EC2 instance itself did not need to be rebuilt or replaced. Terraform updated only the security group.

### What I Learned

This troubleshooting exercise demonstrated that SSH connectivity depends on the complete network path between my computer and the EC2 instance.

A correct SSH key alone is not enough. The source IP must also be permitted by the EC2 security group's inbound rules.

I also learned how Terraform can identify and apply a targeted in-place infrastructure change without recreating unrelated resources.

# Week 4 - Remote State and Terraform CI

## Objective

Move Terraform state to an S3 backend and configure GitHub Actions to validate Terraform configuration using GitHub-to-AWS OIDC authentication.

## Remote State Backend

Configured the Terraform S3 backend in `main.tf` with:

- Bucket: `cloudclimb-project01-tfstate-511126655924-us-east-2-an`
- State key: `cloudclimb-project01/terraform.tfstate`
- Region: `us-east-2`
- Encryption: enabled
- State locking: enabled with `use_lockfile = true`

Migrated the existing Terraform state with Terraform's backend migration workflow rather than starting with an empty state.

After initialization, `terraform state list` returned 25 state entries, confirming that Terraform could access the existing managed-resource state.

## S3 State Security Verification

Verified the bucket configuration using AWS CLI read-only commands:

- S3 versioning: enabled.
- S3 Block Public Access: all four controls enabled.
- Default server-side encryption: AES256 (SSE-S3).
- State locking: configured through the S3 backend's lock file.

Versioning supports recovery of previous state-object versions. Encryption protects stored data at rest, while Block Public Access helps prevent public exposure. State locking helps prevent concurrent Terraform operations from modifying the same state simultaneously.

## GitHub Actions and OIDC

Configured GitHub Actions to authenticate to AWS through OpenID Connect (OIDC) and assume the `CloudClimbGitHubActionsRole` IAM role.

The role's trust policy restricts assumption to the intended GitHub repository and `main` branch. Its permissions are scoped to the Terraform state and lock-file paths, along with the required AWS identity check.

The workflow performs:

- Terraform formatting checks.
- Terraform initialization without a backend for pull requests.
- S3 backend initialization on pushes to `main`.
- Terraform configuration validation.
- AWS identity verification on pushes to `main`.

The workflow does not run `terraform apply`.

## Final Verification

Ran `terraform init` successfully and confirmed that `terraform state list` returned 25 entries.

Ran `terraform plan` and received:

`No changes. Your infrastructure matches the configuration.`

Verified S3 versioning, public-access protections, and server-side encryption through AWS CLI.

## Lessons Learned

- Remote state allows Terraform to manage infrastructure using a shared backend instead of relying exclusively on local state.
- Migrating existing state preserves Terraform's record of resources already under management.
- State locking, versioning, encryption, and access controls address different risks.
- OIDC allows GitHub Actions to assume an AWS role using temporary credentials instead of long-lived AWS access keys.
- Terraform formatting and validation checks do not deploy infrastructure.
- Sensitive variables still affect Terraform plans. An unexpected password change should be investigated before applying any plan.
- A clean plan confirms that the current input values and configuration produce no proposed changes at the time of the check.

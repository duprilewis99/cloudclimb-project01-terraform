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

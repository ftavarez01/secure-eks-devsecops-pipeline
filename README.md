# IN CONSTRUCTION YET.

# 🛡️ Secure Microservice Deployment on AWS EKS

This project implements a **Production-Ready DevSecOps Environment** on AWS. It follows the "Secure-by-Design" principle, ensuring that every layer—from the network to the running container—is protected, monitored, and automated.

# 📐 Architecture Design

The following diagram illustrates the infrastructure and security layers implemented using Terraform. It highlights the network isolation, identity management (IRSA), and the runtime security monitoring.

![EKS Secure Architecture](./images/Architecture-Diagram.png)

> **Note:** The architecture follows the **AWS Well-Architected Framework**, specifically focusing on the Security and Reliability pillars.

---

# 🏗️ Technical Architecture Layers

## 1. Network Layer (The Foundation)
* **Multi-AZ Deployment:** Infrastructure is spread across two **Availability Zones (AZs)** to ensure High Availability (HA).
* **Subnet Segmentation:** * **Public Subnets:** Host the NAT Gateway and the Application Load Balancer (ALB). These are the only components with direct internet exposure.
    * **Private Subnets:** This is where the **EKS Worker Nodes** reside. They have no public IP addresses, significantly reducing the attack surface.
* **Secure Egress:** Nodes access the internet (to pull updates or patches) strictly through the **NAT Gateway**.

## 2. Compute & Orchestration (The Brain)
* **Amazon EKS (Elastic Kubernetes Service):** A managed Kubernetes control plane that eliminates the operational burden of managing master nodes.
* **Managed Node Groups:** Two `t3.medium` instances provide the compute power. They are automatically patched and updated by AWS.
* **EBS CSI Driver:** Enables dynamic provisioning of **Amazon EBS** volumes, allowing stateful applications (like databases) to persist data securely.

## 3. Security & Identity (The Shield)
* **IAM Roles for Service Accounts (IRSA):** Utilizing **OIDC** to map specific AWS IAM Roles to Kubernetes Service Accounts, following the **Principle of Least Privilege**.
* **Runtime Security (Falco):** A security monitor deployed as a DaemonSet using **eBPF** probes to inspect kernel system calls, detecting unauthorized activities like shell executions in real-time.
* **Container Security:** Images are scanned for vulnerabilities using **Trivy** before being pushed to the private registry.

---

## 4. 🛠️ The DevSecOps Workflow

1.  **Code:** Developer pushes code to GitHub.
2.  **Scan:** GitHub Actions triggers **Trivy** to scan the container image for CVEs.
3.  **Store:** Secure images are pushed to **Amazon ECR** (Elastic Container Registry).
4.  **Deploy:** Terraform-managed EKS pulls the image and deploys it into the private subnets.
5.  **Monitor:** **Falco** monitors the running containers for any suspicious behavior.

---

## 5. 📂 Project Structure (IaC)

* `vpc.tf`: Network foundation including ( VPC, Public/Private Subnets, Internet Gateway, and NAT Gateway for secure egress).
* `eks.tf`: Amazon EKS Cluster configuration and Managed Node Groups (EC2 Workers) definition.
* `eks-addons.tf`: Management of critical Kubernetes extensions, specifically the Amazon **EBS CSI Driver** for storage persistence.
* `security.tf`: Implementation of Runtime Security using **Falco** deployed via (**Helm provider**) to monitor kernel system calls.
* `security-groups.tf`: Fine-grained firewall rules (Security Groups) for the EKS Cluster and Node communication.
* `providers.tf`: Manages the connection to **AWS** and orchestrates the configuration for **Kubernetes** and **Helm providers**, including required versions for infrastructure consistency.
* `variables.tf`: Input variables to make the infrastructure reusable and configurable **(Region, Cluster Name, CIDRs)**.
* `outputs.tf`: Essential infrastructure data exported after deployment **(Cluster Endpoint, Security Group IDs, Kubeconfig details)**.
* `ecr.tf`: Private Container Registry ( **ECR** )


---

## 6. 🏗️ Technical Architecture Layers (Additions)

### Container Registry & Lifecycle (The Vault):

* `Amazon ECR`: A private registry configured with IMMUTABLE tags to prevent image tampering and KMS Encryption for data at rest.

* `Lifecycle Policies`: Automated rules to retain only the 5 most recent images, ensuring cost-optimization and staying within the AWS Free Tier limits.

* `Scan-on-Push`: Integrated vulnerability scanning that triggers every time a new image is uploaded.

---

## 7. 🛠️ The DevSecOps Pipeline (GitHub Actions)

The project implements an automated **"Security Guardian"** workflow located at `.github/workflows/deploy.yml`. This pipeline ensures that only scanned and verified code reaches the production environment.

### 🛡️ Workflow Stages

*  **Checkout Code:** Clones the repository into the GitHub runner environment.
*  **Build Image:** Builds a Docker image based on the project's `Dockerfile`.
*  **Vulnerability Scan (Trivy):** 🚨 **Critical Security Gate.** Scans the container image for **CVEs** (Common Vulnerabilities and Exposures). If **CRITICAL** vulnerabilities are detected, the pipeline fails immediately, blocking the deployment.
*   **AWS Authentication:** Uses **GitHub Repository Secrets** (`AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY`) to securely authenticate with AWS.
*  **ECR Push:** Once verified as secure, the image is tagged and pushed to the private **Amazon ECR** repository managed by Terraform.

---

## 8. 🚀 How to Deploy

### Infrastructure Provisioning
Initialize and apply the Terraform configuration to create the VPC, EKS cluster, and ECR repository:

```bash
cd terraform
terraform init
terraform apply -auto-approve
```
---
## 9. CI/CD Setup

* `Configure Secrets`: Navigate to your GitHub Repository Settings > Secrets and variables > Actions and add the following secrets:
```bash
 AWS_ACCESS_KEY_ID: Your AWS access key.
 AWS_SECRET_ACCESS_KEY: Your AWS secret key.
 ECR_REPOSITORY_URL: The URL obtained from the terraform output.
```
* `Trigger Deployment`: Push your code to the main branch to trigger the automated security scan and ECR deployment.

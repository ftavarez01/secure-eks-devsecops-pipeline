# 🛡️ Secure Microservice Deployment on AWS EKS

This project implements a **Production-Ready DevSecOps Environment** on AWS. It follows the "Secure-by-Design" principle, ensuring that every layer—from the network to the running container—is protected, monitored, and automated.

## 📐 Architecture Design

The following diagram illustrates the infrastructure and security layers implemented using Terraform. It highlights the network isolation, identity management (IRSA), and the runtime security monitoring.

![EKS Secure Architecture](./images/Architecture-Diagram.png)

> **Note:** The architecture follows the **AWS Well-Architected Framework**, specifically focusing on the Security and Reliability pillars.

---

## 🏗️ Technical Architecture Layers

### 1. Network Layer (The Foundation)
* **Multi-AZ Deployment:** Infrastructure is spread across two **Availability Zones (AZs)** to ensure High Availability (HA).
* **Subnet Segmentation:** * **Public Subnets:** Host the NAT Gateway and the Application Load Balancer (ALB). These are the only components with direct internet exposure.
    * **Private Subnets:** This is where the **EKS Worker Nodes** reside. They have no public IP addresses, significantly reducing the attack surface.
* **Secure Egress:** Nodes access the internet (to pull updates or patches) strictly through the **NAT Gateway**.

### 2. Compute & Orchestration (The Brain)
* **Amazon EKS (Elastic Kubernetes Service):** A managed Kubernetes control plane that eliminates the operational burden of managing master nodes.
* **Managed Node Groups:** Two `t3.medium` instances provide the compute power. They are automatically patched and updated by AWS.
* **EBS CSI Driver:** Enables dynamic provisioning of **Amazon EBS** volumes, allowing stateful applications (like databases) to persist data securely.

### 3. Security & Identity (The Shield)
* **IAM Roles for Service Accounts (IRSA):** Utilizing **OIDC** to map specific AWS IAM Roles to Kubernetes Service Accounts, following the **Principle of Least Privilege**.
* **Runtime Security (Falco):** A security monitor deployed as a DaemonSet using **eBPF** probes to inspect kernel system calls, detecting unauthorized activities like shell executions in real-time.
* **Container Security:** Images are scanned for vulnerabilities using **Trivy** before being pushed to the private registry.

---

## 🛠️ The DevSecOps Workflow

1.  **Code:** Developer pushes code to GitHub.
2.  **Scan:** GitHub Actions triggers **Trivy** to scan the container image for CVEs.
3.  **Store:** Secure images are pushed to **Amazon ECR** (Elastic Container Registry).
4.  **Deploy:** Terraform-managed EKS pulls the image and deploys it into the private subnets.
5.  **Monitor:** **Falco** monitors the running containers for any suspicious behavior.

---

## 📂 Project Structure (IaC)
* `vpc.tf`: Network foundation including ( VPC, Public/Private Subnets, Internet Gateway, and NAT Gateway for secure egress).
* `eks.tf`: Amazon EKS Cluster configuration and Managed Node Groups (EC2 Workers) definition.
* `eks-addons.tf`: Management of critical Kubernetes extensions, specifically the Amazon **EBS CSI Driver** for storage persistence.
* `security.tf`: Implementation of Runtime Security using **Falco** deployed via (**Helm provider**) to monitor kernel system calls.
* `security-groups.tf`: Fine-grained firewall rules (Security Groups) for the EKS Cluster and Node communication.
* `providers.tf`: Manages the connection to **AWS** and orchestrates the configuration for **Kubernetes** and **Helm providers**, including required versions for infrastructure consistency.
* `variables.tf`: Input variables to make the infrastructure reusable and configurable **(Region, Cluster Name, CIDRs)**.
* `outputs.tf`: Essential infrastructure data exported after deployment **(Cluster Endpoint, Security Group IDs, Kubeconfig details)**.


---

## 🚀 Deployment & Verification

### 1. Provisioning
```bash
cd terraform
terraform init
terraform apply -auto-approve

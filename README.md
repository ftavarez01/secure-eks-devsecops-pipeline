# Secure Microservice Deployment on AWS EKS

🌐 Project Architecture Overview
This project implements a Production-Ready DevSecOps Environment on AWS. It focuses on the "Secure-by-Design" principle, ensuring that every layer—from the network to the running container—is protected and monitored.

🏗️ Technical Architecture Layers
1. Network Layer (The Foundation)
Multi-AZ Deployment: The Infrastructure is spread across two Availability Zones (AZs) to ensure High Availability (HA). If one AWS data center fails, the application stays online.

Subnet Segmentation: * Public Subnets: Host the NAT Gateway and the Application Load Balancer (ALB). These are the only components with direct internet exposure.

Private Subnets: This is where the EKS Worker Nodes reside. They have no public IP addresses, significantly reducing the attack surface.

Secure Egress: Nodes access the internet (to pull Docker images or security patches) strictly through the NAT Gateway.

2. Compute & Orchestration (The Brain)
Amazon EKS (Elastic Kubernetes Service): A managed Kubernetes control plane that eliminates the operational burden of managing master nodes.

Managed Node Groups: Two t3.medium instances provide the compute power. They are automatically patched and updated by AWS.

EBS CSI Driver: Enables dynamic provisioning of Amazon EBS volumes, allowing stateful applications (like databases) to persist data even if a pod or node restarts.

3. Security & Identity (The Shield)
IAM Roles for Service Accounts (IRSA): Instead of giving broad permissions to the entire EC2 node, we use OpenID Connect (OIDC) to map specific AWS IAM Roles to Kubernetes Service Accounts. This follows the Principle of Least Privilege.

Runtime Security (Falco): A security monitor is deployed as a DaemonSet. It uses eBPF probes to inspect kernel system calls, detecting unauthorized activities like shell executions or sensitive file access in real-time.

Container Security: Images are scanned for vulnerabilities using Trivy before being pushed to the private Amazon ECR registry.

🛠️ The DevSecOps Workflow
Code: Developer pushes code to GitHub.

Scan: GitHub Actions triggers Trivy to scan the container image for CVEs.

Store: Secure images are pushed to Amazon ECR.

Deploy: Terraform-managed EKS pulls the image and deploys it into the private subnets.

Monitor: Falco monitors the running container for any suspicious behavior.

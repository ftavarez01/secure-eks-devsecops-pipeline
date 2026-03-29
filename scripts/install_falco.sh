#!/bin/bash

# ==============================================================================
# Script: install_falco.sh
# Description: Installs Falco with eBPF driver on Amazon EKS for Runtime Security
# ==============================================================================

set -e  # Exit immediately if a command exits with a non-zero status

# Terminal Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
FALCOCOMMAND='kubectl get pods -n falco'
echo -e "${BLUE}🔍 Checking Prerequisites...${NC}"

# 1. Validate if Helm is installed
if ! command -v helm &> /dev/null; then
    echo "❌ Error: Helm is not installed. Please install it using 'sudo dnf install helm'."
    exit 1
fi

# 2. Validate EKS Connection
echo -e "${BLUE}☸️  Verifying EKS Connection...${NC}"
kubectl cluster-info || { echo "❌ Error: Could not connect to the cluster. Please check your kubeconfig."; exit 1; }

# 3. Add and Update Falco Repository
echo -e "${BLUE}📦 Adding Falco Helm Repository...${NC}"
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# 4. Install Falco
echo -e "${GREEN}🚀 Installing Falco in 'falco' namespace (eBPF Mode)...${NC}"
# We use eBPF as it's more modern and doesn't require loading kernel modules on AWS nodes.
helm install falco falcosecurity/falco \
  --namespace falco \
  --create-namespace \
  --set driver.kind=ebpf \
  --set tty=true \
  --set falcosidekick.enabled=true \
  --set falcosidekick.webui.enabled=true

echo -e "${GREEN}✅ Falco installed successfully!${NC}"
echo -e "${BLUE}👉 Executing command: 'kubectl get pods -n falco' to check the status.${NC}"
${FALCOCOMMAND}

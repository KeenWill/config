# Kubernetes GitOps Configuration

This directory contains Kubernetes manifests that are automatically applied to the cluster through Flux GitOps.

## Directory Structure

- `apps/`: Application-specific manifests and Helm releases
- `core/`: Core cluster components (networking, storage, etc.)
- `monitoring/`: Monitoring stack (Prometheus, Grafana, etc.)
- `storage/`: Storage-related configurations and persistence

## Getting Started

1. Install NixOS with the k3s module on your server:
   ```bash
   nixos-rebuild switch
   ```

2. Wait for Flux to bootstrap and apply these configurations automatically.

3. Check the status of your cluster:
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

## Adding New Applications

To add a new application:

1. Create a new directory in the appropriate location (usually under `apps/`)
2. Add the necessary Kubernetes manifests or Helm chart values
3. Commit and push changes to the Git repository
4. Flux will automatically apply the changes to the cluster

## Secret Management

Secrets are managed using SOPS. To create a new secret:

1. Create a YAML file with your secret data
2. Encrypt it with SOPS using your configured age or GPG key
3. Commit the encrypted file to the repository
4. Flux will automatically decrypt and apply the secret to the cluster

## Troubleshooting

If you encounter issues with the deployment:

1. Check Flux logs:
   ```bash
   kubectl logs -n flux-system deployment/source-controller
   kubectl logs -n flux-system deployment/kustomize-controller
   ```

2. Verify that Flux has detected changes:
   ```bash
   flux get kustomizations
   flux get helmreleases
   ```

3. Check the k3s service status:
   ```bash
   systemctl status k3s
   ```
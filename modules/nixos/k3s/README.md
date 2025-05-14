# NixOS K3s Module

This module provides a complete K3s Kubernetes setup for NixOS, including:

- K3s Kubernetes deployment
- Flux GitOps integration
- SOPS secret management
- Renovate dependency updates
- Bootstrap scripts

## Usage

To use this module, import it in your NixOS configuration:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./path/to/modules/nixos/k3s/k3s-server.nix
  ];

  # Override any configuration options as needed
  services.k3s = {
    # Custom settings here
  };
}
```

## Configuration Options

### K3s Configuration

- `services.k3s.enable`: Enable K3s
- `services.k3s.role`: Server or agent role
- `services.k3s.serverAddr`: Server address for agent nodes
- `services.k3s.clusterInit`: Whether to initialize the cluster
- `services.k3s.disableComponents`: List of built-in components to disable
- `services.k3s.extraFlags`: Additional flags for k3s

### Flux Configuration

- `services.fluxcd.enable`: Enable Flux GitOps
- `services.fluxcd.gitRepository`: Git repository URL
- `services.fluxcd.branch`: Git branch to use
- `services.fluxcd.path`: Path within the repository
- `services.fluxcd.interval`: Sync interval
- `services.fluxcd.deployKey`: SSH key for Git repository

### SOPS Configuration

- `sops.enable`: Enable SOPS secret management
- `sops.age.keyFile`: Path to age key file
- `sops.age.generateKey`: Whether to generate a key if missing
- `sops.secrets`: Secret definitions
- `sops.defaultSopsFile`: Default SOPS file

### Bootstrap Configuration

- `k3s.bootstrap.enable`: Enable bootstrap script
- `k3s.bootstrap.script`: Custom bootstrap script content

### Renovate Configuration

- `services.renovate.enable`: Enable Renovate
- `services.renovate.gitRepository`: Git repository to update
- `services.renovate.configFile`: Renovate configuration file
- `services.renovate.schedule`: Update schedule
- `services.renovate.tokenFile`: GitHub/GitLab token file

## Directory Structure

```
kubernetes/
├── apps/       # Application manifests
├── core/       # Core cluster components
├── monitoring/ # Monitoring stack
└── storage/    # Storage configurations
```

## Getting Started

1. Configure your NixOS system to use this module
2. Set up a Git repository for Flux GitOps
3. Deploy with `nixos-rebuild switch`
4. Check the status with `kubectl get pods -A`

## Secret Management

Use SOPS to manage secrets:

```bash
# Generate an age key
age-keygen -o age.key

# Add public key to .sops.yaml
# Encrypt a secret
sops -e --age=age1... secret.yaml > secret.enc.yaml
```

## Troubleshooting

If you encounter issues:

1. Check K3s logs: `journalctl -u k3s`
2. Check Flux logs: `kubectl logs -n flux-system deployment/source-controller`
3. Verify connectivity: `kubectl get nodes`
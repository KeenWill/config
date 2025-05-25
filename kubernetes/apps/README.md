# Kubernetes Applications

This directory contains applications deployed on your k3s Kubernetes cluster.

## Applications

### Caddy
- **Purpose**: Reverse proxy and ingress controller
- **Ports**: 80, 443
- **URL**: N/A (used as the ingress for other services)
- **Notes**: Services define their domains with the `caddy.ingress/host` annotation

### Tailscale
- **Purpose**: Secure network connectivity using Tailscale VPN
- **URL**: Managed through Tailscale admin console
- **Notes**: Requires Tailscale auth key

### Syncthing
- **Purpose**: File synchronization between devices
- **URL**: https://syncthing.example.com
- **Ports**: 8384 (Web UI), 22000 (Sync), 21027 (Discovery)

### Plex
- **Purpose**: Media server for video content
- **URL**: https://plex.example.com
- **Ports**: 32400 (Web UI), various others for discovery
- **Notes**: Requires a Plex claim token during initial setup

### Jellyfin
- **Purpose**: Open source media server alternative
- **URL**: https://jellyfin.example.com
- **Ports**: 8096 (HTTP)

### Gitea
- **Purpose**: Self-hosted Git service and repository manager
- **URL**: https://gitea.example.com
- **Ports**: 3000 (Web UI), 22 (SSH)
- **Notes**: Uses PostgreSQL as a database backend

### Grafana & Prometheus
- **Purpose**: Monitoring and observability
- **URLs**: 
  - https://grafana.example.com
  - https://prometheus.example.com
- **Ports**: 3000 (Grafana), 9090 (Prometheus)
- **Default Credentials**: admin/admin

### Ollama
- **Purpose**: Self-hosted AI model server
- **URL**: https://ollama.example.com
- **Ports**: 11434
- **Models**: Includes llama2, mistral

### *Arr Services
- **Purpose**: Media management services
- **URLs**:
  - https://sonarr.example.com - TV Shows (Port 8989)
  - https://radarr.example.com - Movies (Port 7878)
  - https://lidarr.example.com - Music (Port 8686)
  - https://prowlarr.example.com - Indexer (Port 9696)

### Filebrowser
- **Purpose**: Web-based file manager
- **URL**: https://files.example.com
- **Ports**: 80
- **Default Credentials**: admin/admin

## Deployment Notes

1. Edit hostnames:
   - Replace `example.com` in the manifests with your actual domain
   - Update the `caddy.ingress/host` annotations accordingly

2. Configure persistent storage:
   - Storage claims point to the local-path provisioner
   - Consider adding backup solutions for important data

3. Sensitive information:
   - Replace placeholder secrets (like Tailscale auth key)
   - Use SOPS for sensitive configurations

4. Hardware considerations:
   - Resource requests/limits may need adjustment based on your server hardware
   - GPU-accelerated services (like Ollama or Plex transcoding) may require additional configuration

5. Networking:
   - Services are exposed through Caddy or Tailscale
   - Verify firewall rules to allow relevant traffic

## Customization

Each application has its own directory with the following files:
- `deployment.yaml`: The main Kubernetes deployment configuration
- `kustomization.yaml`: Kustomize configuration for the application
- (Optional) Additional configurations specific to the application
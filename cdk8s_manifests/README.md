# CDK8s+ Kubernetes Manifests

This project contains Kubernetes manifests written using Python CDK8s+ with Helm charts.

## Prerequisites

- Python 3.8+
- pip
- Node.js 14+ (for cdk8s CLI)
- kubectl
- Helm 3+

## Installation

1. Install the cdk8s CLI:

```bash
npm install -g cdk8s-cli
```

2. Install Python dependencies:

```bash
pip install -r requirements.txt
```

## Project Structure

```
cdk8s_manifests/
├── charts/           # CDK8s chart implementations
│   ├── core.py       # Core infrastructure (namespaces)
│   ├── arr_services.py  # Sonarr, Radarr, etc.
│   ├── caddy.py      # Caddy as ingress controller
│   └── ...           # Other application charts
├── lib/              # Shared libraries and utilities
│   ├── chart.py      # Base chart class
│   └── helm.py       # Helm chart wrapper
├── imports/          # Generated Kubernetes types
└── main.py           # Main application entry point
```

## Usage

1. Configure the charts in the `charts/` directory according to your environment.

2. Synthesize the Kubernetes manifests:

```bash
cdk8s synth
```

3. Apply the generated manifests:

```bash
kubectl apply -f dist/
```

## Adding New Charts

1. Create a new chart file in the `charts/` directory
2. Implement the chart using cdk8s+ constructs and Helm charts
3. Import and instantiate your chart in `main.py`

## Available Charts

- **Core**: Basic namespace structure
- **ArrServices**: Sonarr, Radarr, Lidarr, Prowlarr
- **Caddy**: Ingress controller
- **FileBrowser**: Web file manager
- **Gitea**: Git server
- **Grafana/Prometheus**: Monitoring stack
- **Jellyfin**: Media server
- **Ollama**: AI model server
- **Plex**: Media server
- **Syncthing**: File synchronization
- **Tailscale**: Network connectivity

## Configuration

Edit the values in each chart's configuration to match your environment:

- Update hostnames in ingress configurations
- Set appropriate resource limits
- Configure persistence sizes
- Update secrets (don't commit actual secrets to git!)

## License

MIT
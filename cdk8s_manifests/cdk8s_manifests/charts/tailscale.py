from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class TailscaleChart(BaseChart):
    """Chart for Tailscale connectivity."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="networking")
        
        # Use the Tailscale Operator Helm chart
        tailscale_operator = HelmChart(
            self, "tailscale-operator",
            chart_name="tailscale-operator",
            repository="https://pkgs.tailscale.com/helmcharts",
            namespace=self.namespace_name,
            values={
                "operator": {
                    "image": {
                        "repository": "tailscale/k8s-operator",
                        "tag": "latest",
                        "pullPolicy": "IfNotPresent"
                    },
                    "oauth": {
                        "clientId": "my-client-id",      # Replace with actual client ID
                        "clientSecret": "my-client-secret"  # Replace with actual client secret
                    }
                },
                "webhook": {
                    "enabled": True
                },
                "imagePullSecrets": [],
                "rbac": {
                    "create": True
                },
                "serviceAccount": {
                    "create": True,
                    "name": "tailscale-operator"
                }
            }
        )
        
        # Deploy a Tailscale proxy example
        self.deploy_tailscale_proxy()
    
    def deploy_tailscale_proxy(self):
        """Deploy a Tailscale proxy for an internal service."""
        proxy = HelmChart(
            self, "tailscale-proxy",
            chart_name="tailscale-proxy",  # This might be a custom chart
            repository="https://pkgs.tailscale.com/helmcharts",
            namespace=self.namespace_name,
            values={
                "hostname": "k8s-proxy",
                "image": {
                    "repository": "tailscale/tailscale",
                    "tag": "latest"
                },
                "config": {
                    "authkey": "tskey-123456",  # Replace with actual auth key
                    "tags": ["tag:k8s"]
                },
                "proxy": {
                    "service": "internal-service.default.svc.cluster.local",
                    "port": 80
                },
                "ingress": {
                    "enabled": False
                },
                "persistence": {
                    "enabled": True,
                    "size": "1Gi"
                }
            }
        )
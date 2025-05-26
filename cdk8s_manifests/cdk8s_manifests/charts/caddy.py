from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class CaddyChart(BaseChart):
    """Chart for Caddy as an ingress controller."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="networking")
        
        # Use the caddy-ingress-controller Helm chart
        caddy = HelmChart(
            self, "caddy",
            chart_name="caddy-ingress-controller",
            repository="https://caddyserver.github.io/ingress/",
            namespace=self.namespace_name,
            values={
                "controller": {
                    "image": {
                        "repository": "caddy",
                        "tag": "2.7.4-alpine",
                        "pullPolicy": "IfNotPresent"
                    },
                    "config": {
                        "email": "admin@example.com"
                    },
                    "resources": {
                        "requests": {
                            "cpu": "100m",
                            "memory": "128Mi"
                        },
                        "limits": {
                            "cpu": "500m",
                            "memory": "512Mi"
                        }
                    }
                },
                "service": {
                    "type": "LoadBalancer",
                    "ports": {
                        "http": 80,
                        "https": 443
                    }
                },
                "persistence": {
                    "enabled": True,
                    "size": "1Gi",
                    "storageClass": "standard"
                },
                "metrics": {
                    "enabled": True,
                    "serviceMonitor": {
                        "enabled": True
                    }
                },
                "rbac": {
                    "create": True
                },
                "serviceAccount": {
                    "create": True,
                    "name": "caddy-ingress-controller"
                }
            }
        )
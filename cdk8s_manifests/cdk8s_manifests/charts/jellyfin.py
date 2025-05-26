from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class JellyfinChart(BaseChart):
    """Chart for Jellyfin media server."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="media")
        
        # Use the Jellyfin Helm chart
        jellyfin = HelmChart(
            self, "jellyfin",
            chart_name="jellyfin",
            repository="https://k8s-at-home.com/charts/",
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "jellyfin/jellyfin",
                    "tag": "latest",
                    "pullPolicy": "IfNotPresent"
                },
                "env": {
                    "TZ": "UTC",
                    "JELLYFIN_PublishedServerUrl": "jellyfin.example.com"
                },
                "service": {
                    "main": {
                        "ports": {
                            "http": {
                                "port": 8096
                            }
                        }
                    }
                },
                "ingress": {
                    "main": {
                        "enabled": True,
                        "hosts": [
                            {
                                "host": "jellyfin.example.com",
                                "paths": [
                                    {
                                        "path": "/",
                                        "pathType": "Prefix"
                                    }
                                ]
                            }
                        ]
                    }
                },
                "persistence": {
                    "config": {
                        "enabled": True,
                        "mountPath": "/config",
                        "size": "5Gi"
                    },
                    "cache": {
                        "enabled": True,
                        "mountPath": "/cache",
                        "size": "5Gi"
                    },
                    "media": {
                        "enabled": True,
                        "mountPath": "/media",
                        "size": "50Gi"
                    }
                },
                "resources": {
                    "requests": {
                        "cpu": "1",
                        "memory": "2Gi"
                    },
                    "limits": {
                        "cpu": "4",
                        "memory": "4Gi"
                    }
                },
                "podSecurityContext": {
                    "runAsUser": 1000,
                    "runAsGroup": 1000,
                    "fsGroup": 1000
                }
            }
        )
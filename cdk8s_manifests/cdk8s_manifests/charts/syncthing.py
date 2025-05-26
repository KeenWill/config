from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class SyncthingChart(BaseChart):
    """Chart for Syncthing file synchronization."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="storage")
        
        # Use the k8s-at-home Syncthing Helm chart
        syncthing = HelmChart(
            self, "syncthing",
            chart_name="syncthing",
            repository="https://k8s-at-home.com/charts/",
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "linuxserver/syncthing",
                    "tag": "latest",
                    "pullPolicy": "IfNotPresent"
                },
                "env": {
                    "TZ": "UTC",
                    "PUID": "1000",
                    "PGID": "1000"
                },
                "service": {
                    "main": {
                        "ports": {
                            "http": {
                                "port": 8384
                            }
                        }
                    },
                    "sync": {
                        "enabled": True,
                        "ports": {
                            "sync": {
                                "port": 22000,
                                "protocol": "TCP"
                            }
                        }
                    },
                    "discovery": {
                        "enabled": True,
                        "ports": {
                            "discovery": {
                                "port": 21027,
                                "protocol": "UDP"
                            }
                        }
                    }
                },
                "ingress": {
                    "main": {
                        "enabled": True,
                        "hosts": [
                            {
                                "host": "syncthing.example.com",
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
                        "size": "1Gi"
                    },
                    "data": {
                        "enabled": True,
                        "mountPath": "/data",
                        "size": "10Gi"
                    }
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
            }
        )
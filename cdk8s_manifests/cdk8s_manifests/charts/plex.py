from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class PlexChart(BaseChart):
    """Chart for Plex Media Server."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="media")
        
        # Use the k8s-at-home Helm chart for Plex
        plex = HelmChart(
            self, "plex",
            chart_name="plex",
            repository="https://k8s-at-home.com/charts/",
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "plexinc/pms-docker",
                    "tag": "latest",
                    "pullPolicy": "IfNotPresent"
                },
                "env": {
                    "TZ": "UTC",
                    "PLEX_CLAIM": ""  # This should be set during deployment
                },
                "service": {
                    "main": {
                        "type": "ClusterIP",
                        "ports": {
                            "http": {
                                "port": 32400,
                                "targetPort": 32400
                            }
                        }
                    }
                },
                "ingress": {
                    "main": {
                        "enabled": True,
                        "hosts": [
                            {
                                "host": "plex.example.com",
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
                        "size": "10Gi"
                    },
                    "transcode": {
                        "enabled": True,
                        "mountPath": "/transcode",
                        "emptyDir": {
                            "medium": "Memory"
                        }
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
                        "memory": "8Gi"
                    }
                }
            }
        )
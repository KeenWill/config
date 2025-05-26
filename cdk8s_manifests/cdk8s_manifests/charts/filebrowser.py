from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class FileBrowserChart(BaseChart):
    """Chart for FileBrowser web file manager."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="storage")
        
        # Use a generic Helm chart for FileBrowser
        filebrowser = HelmChart(
            self, "filebrowser",
            chart_name="filebrowser",
            repository="https://k8s-at-home.com/charts/",  # or use a generic chart repo
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "filebrowser/filebrowser",
                    "tag": "v2.22.4",
                    "pullPolicy": "IfNotPresent"
                },
                "env": {
                    "FB_BASEURL": "",
                    "FB_ROOT": "/srv",
                    "FB_AUTH_METHOD": "json"
                },
                "service": {
                    "main": {
                        "ports": {
                            "http": {
                                "port": 80,
                                "targetPort": 80
                            }
                        }
                    }
                },
                "ingress": {
                    "main": {
                        "enabled": True,
                        "hosts": [
                            {
                                "host": "files.example.com",
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
                        "mountPath": "/database",
                        "size": "1Gi"
                    },
                    "data": {
                        "enabled": True,
                        "mountPath": "/srv",
                        "size": "10Gi"
                    }
                },
                "resources": {
                    "requests": {
                        "cpu": "50m",
                        "memory": "64Mi"
                    },
                    "limits": {
                        "cpu": "200m",
                        "memory": "256Mi"
                    }
                },
                "securityContext": {
                    "runAsUser": 1000,
                    "runAsGroup": 1000,
                    "fsGroup": 1000
                }
            }
        )
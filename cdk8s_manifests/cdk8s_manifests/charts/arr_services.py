from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class ArrServicesChart(BaseChart):
    """Chart for *arr services (Sonarr, Radarr, Lidarr, Prowlarr)."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="media")
        
        # Deploy Sonarr
        self.deploy_sonarr()
        
        # Deploy Radarr
        self.deploy_radarr()
        
        # Deploy Lidarr
        self.deploy_lidarr()
        
        # Deploy Prowlarr
        self.deploy_prowlarr()
    
    def deploy_sonarr(self):
        """Deploy Sonarr using Helm chart."""
        HelmChart(
            self, "sonarr",
            chart_name="sonarr",
            repository="https://k8s-at-home.com/charts/",
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "linuxserver/sonarr",
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
                                "port": 8989
                            }
                        }
                    }
                },
                "ingress": {
                    "main": {
                        "enabled": True,
                        "hosts": [
                            {
                                "host": "sonarr.example.com",
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
                    "media": {
                        "enabled": True,
                        "mountPath": "/media",
                        "size": "10Gi"
                    },
                    "downloads": {
                        "enabled": True,
                        "mountPath": "/downloads",
                        "size": "10Gi"
                    }
                }
            }
        )
    
    def deploy_radarr(self):
        """Deploy Radarr using Helm chart."""
        HelmChart(
            self, "radarr",
            chart_name="radarr",
            repository="https://k8s-at-home.com/charts/",
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "linuxserver/radarr",
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
                                "port": 7878
                            }
                        }
                    }
                },
                "ingress": {
                    "main": {
                        "enabled": True,
                        "hosts": [
                            {
                                "host": "radarr.example.com",
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
                    "media": {
                        "enabled": True,
                        "mountPath": "/media",
                        "size": "10Gi"
                    },
                    "downloads": {
                        "enabled": True,
                        "mountPath": "/downloads",
                        "size": "10Gi"
                    }
                }
            }
        )
    
    def deploy_lidarr(self):
        """Deploy Lidarr using Helm chart."""
        HelmChart(
            self, "lidarr",
            chart_name="lidarr",
            repository="https://k8s-at-home.com/charts/",
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "linuxserver/lidarr",
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
                                "port": 8686
                            }
                        }
                    }
                },
                "ingress": {
                    "main": {
                        "enabled": True,
                        "hosts": [
                            {
                                "host": "lidarr.example.com",
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
                    "media": {
                        "enabled": True,
                        "mountPath": "/media",
                        "size": "10Gi"
                    },
                    "downloads": {
                        "enabled": True,
                        "mountPath": "/downloads",
                        "size": "10Gi"
                    }
                }
            }
        )
    
    def deploy_prowlarr(self):
        """Deploy Prowlarr using Helm chart."""
        HelmChart(
            self, "prowlarr",
            chart_name="prowlarr",
            repository="https://k8s-at-home.com/charts/",
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "linuxserver/prowlarr",
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
                                "port": 9696
                            }
                        }
                    }
                },
                "ingress": {
                    "main": {
                        "enabled": True,
                        "hosts": [
                            {
                                "host": "prowlarr.example.com",
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
                    }
                }
            }
        )
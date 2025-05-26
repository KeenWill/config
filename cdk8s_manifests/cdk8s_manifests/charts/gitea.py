from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class GiteaChart(BaseChart):
    """Chart for Gitea git server."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="apps")
        
        # Use the Gitea Helm chart
        gitea = HelmChart(
            self, "gitea",
            chart_name="gitea",
            repository="https://dl.gitea.io/charts/",
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "gitea/gitea",
                    "tag": "latest",
                    "pullPolicy": "IfNotPresent"
                },
                "persistence": {
                    "enabled": True,
                    "size": "10Gi"
                },
                "gitea": {
                    "admin": {
                        "username": "gitea_admin",
                        "password": "gitea_admin",  # Should be replaced with a secret
                        "email": "admin@example.com"
                    },
                    "config": {
                        "APP_NAME": "Gitea",
                        "RUN_MODE": "prod",
                        "repository": {
                            "ROOT": "/data/git/gitea-repositories"
                        },
                        "server": {
                            "DOMAIN": "gitea.example.com",
                            "ROOT_URL": "https://gitea.example.com/"
                        },
                        "database": {
                            "DB_TYPE": "postgres",
                            "HOST": "gitea-postgresql:5432",
                            "NAME": "gitea",
                            "USER": "gitea",
                            "PASSWD": "gitea_db_password"  # Should be replaced with a secret
                        },
                        "security": {
                            "INSTALL_LOCK": True
                        }
                    }
                },
                "ingress": {
                    "enabled": True,
                    "hosts": [
                        "gitea.example.com"
                    ]
                },
                "resources": {
                    "requests": {
                        "cpu": "200m",
                        "memory": "256Mi"
                    },
                    "limits": {
                        "cpu": "1",
                        "memory": "1Gi"
                    }
                },
                "postgresql": {
                    "enabled": True,
                    "global": {
                        "postgresql": {
                            "auth": {
                                "username": "gitea",
                                "password": "gitea_db_password",  # Should be replaced with a secret
                                "database": "gitea"
                            }
                        }
                    },
                    "primary": {
                        "persistence": {
                            "enabled": True,
                            "size": "5Gi"
                        }
                    }
                }
            }
        )
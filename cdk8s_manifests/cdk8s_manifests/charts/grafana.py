from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class GrafanaChart(BaseChart):
    """Chart for Grafana and Prometheus monitoring stack."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="monitoring")
        
        # Deploy Prometheus
        self.deploy_prometheus()
        
        # Deploy Grafana
        self.deploy_grafana()
    
    def deploy_prometheus(self):
        """Deploy Prometheus using Helm chart."""
        prometheus = HelmChart(
            self, "prometheus",
            chart_name="prometheus",
            repository="https://prometheus-community.github.io/helm-charts",
            namespace=self.namespace_name,
            values={
                "server": {
                    "persistentVolume": {
                        "enabled": True,
                        "size": "8Gi"
                    },
                    "resources": {
                        "requests": {
                            "cpu": "200m",
                            "memory": "512Mi"
                        },
                        "limits": {
                            "cpu": "1",
                            "memory": "2Gi"
                        }
                    }
                },
                "alertmanager": {
                    "enabled": True,
                    "persistentVolume": {
                        "enabled": True,
                        "size": "2Gi"
                    }
                },
                "nodeExporter": {
                    "enabled": True
                },
                "pushgateway": {
                    "enabled": True
                },
                "serverFiles": {
                    "prometheus.yml": {
                        "scrape_configs": [
                            {
                                "job_name": "prometheus",
                                "static_configs": [
                                    {
                                        "targets": [
                                            "localhost:9090"
                                        ]
                                    }
                                ]
                            },
                            {
                                "job_name": "kubernetes-nodes",
                                "kubernetes_sd_configs": [
                                    {
                                        "role": "node"
                                    }
                                ]
                            }
                        ]
                    }
                }
            }
        )
    
    def deploy_grafana(self):
        """Deploy Grafana using Helm chart."""
        grafana = HelmChart(
            self, "grafana",
            chart_name="grafana",
            repository="https://grafana.github.io/helm-charts",
            namespace=self.namespace_name,
            values={
                "persistence": {
                    "enabled": True,
                    "size": "5Gi"
                },
                "adminPassword": "admin",  # Should be replaced with a secret
                "datasources": {
                    "datasources.yaml": {
                        "apiVersion": 1,
                        "datasources": [
                            {
                                "name": "Prometheus",
                                "type": "prometheus",
                                "url": "http://prometheus-server.monitoring.svc.cluster.local",
                                "access": "proxy",
                                "isDefault": True
                            }
                        ]
                    }
                },
                "dashboardProviders": {
                    "dashboardproviders.yaml": {
                        "apiVersion": 1,
                        "providers": [
                            {
                                "name": "default",
                                "orgId": 1,
                                "folder": "",
                                "type": "file",
                                "disableDeletion": False,
                                "editable": True,
                                "options": {
                                    "path": "/var/lib/grafana/dashboards/default"
                                }
                            }
                        ]
                    }
                },
                "dashboards": {
                    "default": {
                        "kubernetes-cluster": {
                            "url": "https://grafana.com/api/dashboards/315/revisions/3/download",
                            "datasource": "Prometheus"
                        },
                        "node-exporter": {
                            "url": "https://grafana.com/api/dashboards/1860/revisions/22/download",
                            "datasource": "Prometheus"
                        }
                    }
                },
                "ingress": {
                    "enabled": True,
                    "hosts": [
                        "grafana.example.com"
                    ]
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
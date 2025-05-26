from constructs import Construct
from cdk8s_manifests.lib.chart import BaseChart
from cdk8s_manifests.lib.helm import HelmChart

class OllamaChart(BaseChart):
    """Chart for Ollama AI model server."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id, namespace="apps")
        
        # Use the Ollama Helm chart
        ollama = HelmChart(
            self, "ollama",
            chart_name="ollama",
            repository="https://ollama.github.io/helm-charts",  # Assuming this is the repo
            namespace=self.namespace_name,
            values={
                "image": {
                    "repository": "ollama/ollama",
                    "tag": "latest",
                    "pullPolicy": "IfNotPresent"
                },
                "service": {
                    "type": "ClusterIP",
                    "port": 11434
                },
                "ingress": {
                    "enabled": True,
                    "hosts": [
                        {
                            "host": "ollama.example.com",
                            "paths": [
                                {
                                    "path": "/",
                                    "pathType": "Prefix"
                                }
                            ]
                        }
                    ]
                },
                "persistence": {
                    "enabled": True,
                    "size": "50Gi",
                    "mountPath": "/root/.ollama"
                },
                "resources": {
                    "requests": {
                        "cpu": "1",
                        "memory": "4Gi"
                    },
                    "limits": {
                        "cpu": "4",
                        "memory": "16Gi"
                    }
                },
                "models": {
                    "preload": [
                        "llama2",
                        "mistral"
                    ]
                },
                "env": {
                    "OLLAMA_HOST": "0.0.0.0",
                    "OLLAMA_MODELS": "/root/.ollama/models"
                },
                "nodeSelector": {
                    "gpu": "true"  # Assuming we want to run on nodes with GPUs
                }
            }
        )
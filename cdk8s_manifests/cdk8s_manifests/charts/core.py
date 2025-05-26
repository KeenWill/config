from constructs import Construct
from cdk8s_plus_25 import Namespace
from cdk8s_manifests.lib.chart import BaseChart

class CoreChart(BaseChart):
    """Chart for core infrastructure components like namespaces."""
    
    def __init__(self, scope: Construct, id: str):
        super().__init__(scope, id)
        
        # Create all required namespaces
        self.create_namespaces([
            "apps",
            "monitoring",
            "media",
            "storage",
            "networking"
        ])
    
    def create_namespaces(self, namespace_names):
        """Create multiple namespaces."""
        for name in namespace_names:
            Namespace(self, f"{name}-ns", metadata={"name": name})
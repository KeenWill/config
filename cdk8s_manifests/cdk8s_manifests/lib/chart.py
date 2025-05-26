from constructs import Construct
from cdk8s import Chart
from cdk8s_plus_25 import Namespace

class BaseChart(Chart):
    """Base chart with common functionality for all charts."""
    
    def __init__(self, scope: Construct, id: str, namespace: str = None, **kwargs):
        super().__init__(scope, id, **kwargs)
        self.namespace_name = namespace or id
        
        # Create namespace if specified
        if namespace:
            self.namespace = Namespace(self, f"{id}-ns", 
                                     metadata={"name": namespace})
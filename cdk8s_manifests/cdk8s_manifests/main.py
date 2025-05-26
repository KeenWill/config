#!/usr/bin/env python
from constructs import Construct
from cdk8s import App, Chart
from cdk8s_plus_25 import Namespace

from cdk8s_manifests.charts.core import CoreChart
from cdk8s_manifests.charts.arr_services import ArrServicesChart
from cdk8s_manifests.charts.caddy import CaddyChart
from cdk8s_manifests.charts.filebrowser import FileBrowserChart
from cdk8s_manifests.charts.gitea import GiteaChart
from cdk8s_manifests.charts.grafana import GrafanaChart
from cdk8s_manifests.charts.jellyfin import JellyfinChart
from cdk8s_manifests.charts.ollama import OllamaChart
from cdk8s_manifests.charts.plex import PlexChart
from cdk8s_manifests.charts.syncthing import SyncthingChart
from cdk8s_manifests.charts.tailscale import TailscaleChart

app = App()

# Create all charts
CoreChart(app, "core")
ArrServicesChart(app, "arr-services")
CaddyChart(app, "caddy")
FileBrowserChart(app, "filebrowser")
GiteaChart(app, "gitea")
GrafanaChart(app, "grafana")
JellyfinChart(app, "jellyfin")
OllamaChart(app, "ollama")
PlexChart(app, "plex")
SyncthingChart(app, "syncthing")
TailscaleChart(app, "tailscale")

app.synth()
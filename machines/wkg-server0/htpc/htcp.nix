{ config, pkgs, lib, ... }:

let
  # Root directory for all media data and config (equivalent to ${ROOT} in Compose)
  rootDir = "/tank/htpc";     # <-- Change this to your media/config parent directory
  # Default UID/GID and timezone from the Compose .env (adjust as needed)
  PUID    = "1000";                # UID for inside-container user (e.g., your main user’s ID or a media user)
  PGID    = "100";                # GID for inside-container user (e.g., a media group ID)
  TZ      = "America/New_York"; 
in {
  ##### 1. Enable Podman (rootless) #####
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerCompat = true;  # optional: allows using `docker` command as alias to Podman
  # (Enabling Podman will ensure required configuration for rootless containers)

  ##### 2. Define dedicated system users for each service #####
  # Each container will run as its own unprivileged user for security isolation
  users.groups.vpn = {};      users.users.vpn = {
    isNormalUser = true;
    description = "User for OpenVPN container";
    group = "vpn";
    home = "/var/lib/vpn";
    createHome = true;
    shell = "/run/current-system/sw/bin/nologin";     # no login shell
    autoSubUidGidRange = true;  # allocate subuid/subgid range for rootless Podman :contentReference[oaicite:4]{index=4}
    linger = true;             # allow user services (ensure /run/user/UID exists)
  };
  users.groups.deluge = {};   users.users.deluge = {
    isNormalUser = true;
    description = "User for Deluge container";
    group = "deluge";
    home = "/var/lib/deluge";
    createHome = true;
    shell = "/run/current-system/sw/bin/nologin";
    autoSubUidGidRange = true;
    linger = true;
  };
  users.groups.jackett = {};  users.users.jackett = {
    isNormalUser = true;
    description = "User for Jackett container";
    group = "jackett";
    home = "/var/lib/jackett";
    createHome = true;
    shell = "/run/current-system/sw/bin/nologin";
    autoSubUidGidRange = true;
    linger = true;
  };
  users.groups.nzbget = {};   users.users.nzbget = {
    isNormalUser = true;
    description = "User for NZBGet container";
    group = "nzbget";
    home = "/var/lib/nzbget";
    createHome = true;
    shell = "/run/current-system/sw/bin/nologin";
    autoSubUidGidRange = true;
    linger = true;
  };
  users.groups.sonarr = {};   users.users.sonarr = {
    isNormalUser = true;
    description = "User for Sonarr container";
    group = "sonarr";
    home = "/var/lib/sonarr";
    createHome = true;
    shell = "/run/current-system/sw/bin/nologin";
    autoSubUidGidRange = true;
    linger = true;
  };
  users.groups.radarr = {};   users.users.radarr = {
    isNormalUser = true;
    description = "User for Radarr container";
    group = "radarr";
    home = "/var/lib/radarr";
    createHome = true;
    shell = "/run/current-system/sw/bin/nologin";
    autoSubUidGidRange = true;
    linger = true;
  };
  users.groups.plex = {};     users.users.plex = {
    isNormalUser = true;
    description = "User for Plex container";
    group = "plex";
    home = "/var/lib/plex";
    createHome = true;
    shell = "/run/current-system/sw/bin/nologin";
    autoSubUidGidRange = true;
    linger = true;
  };
  users.groups.bazarr = {};   users.users.bazarr = {
    isNormalUser = true;
    description = "User for Bazarr container";
    group = "bazarr";
    home = "/var/lib/bazarr";
    createHome = true;
    shell = "/run/current-system/sw/bin/nologin";
    autoSubUidGidRange = true;
    linger = true;
  };

  ##### 3. (Optional) Create a custom Podman network for VPN #####
  # If you want an isolated network for the VPN and Deluge, you can create one:
  systemd.services.create-vpn-network = {
    description = "Podman: create custom network 'vpn-net'";
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-vpn.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.podman}/bin/podman network create vpn-net";
      ExecStop  = "${pkgs.podman}/bin/podman network rm vpn-net";
    };
  };
  # (In this config, we directly use container network sharing for VPN/Deluge, 
  # so this custom network is not strictly required. It’s provided as an example.)

  ##### 4. Define systemd services for each container (using Podman) #####
  # Each container mirrors the docker-compose settings: image, volumes, env, network, etc.
  # The containers will be run via `podman run` commands under the respective user accounts.
  #
  # Note: We use '--network container:vpn' for Deluge to share VPN's network namespace, 
  # and '--network host' for services that use host networking in Compose.
  # Also, we set Restart=always to keep containers running (like "restart: unless-stopped").

  ## VPN Container (OpenVPN client) ##
  systemd.services.podman-vpn = {
    description = "OpenVPN Client container (VPN)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name vpn \
          --cap-add=NET_ADMIN \            # allow modifying network interfaces (for VPN) 
          --device /dev/net/tun:/dev/net/tun \  # attach TUN device
          --security-opt label=disable \   # disable SELinux labeling (matches compose)
          --network host \                 # use host network (or use a user-defined network if created)
          -p 8112:8112/tcp \               # publish Deluge Web UI port to host (for local network access)
          -v /dev/net:/dev/net:z \         # mount /dev/net (tun device directory)
          -v ${rootDir}/config/vpn:/vpn \  # OpenVPN config directory
          -e TZ=${TZ} \                    # timezone environment
          -d dperson/openvpn-client:latest \ 
          -f "" -r 192.168.1.0/24          # command: enable firewall (-f) and route local network traffic (-r)
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop vpn; ${pkgs.podman}/bin/podman rm vpn";
      Restart = "always";
      User = "vpn";
      Group = "vpn";
    };
  };

  ## Deluge (Torrent downloader) ##
  systemd.services.podman-deluge = {
    description = "Deluge Torrent client container";
    after = [ "podman-vpn.service" ];    # ensure VPN container is up first
    requires = [ "podman-vpn.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name deluge \
          --network container:vpn \      # share network with VPN container (all traffic goes through VPN)
          -e PUID=${PUID} \              # user ID inside container (from .env)
          -e PGID=${PGID} \              # group ID inside container
          -e TZ=${TZ} \                  # timezone
          -v ${rootDir}/downloads:/downloads \   # downloads folder
          -v ${rootDir}/config/deluge:/config \  # Deluge config folder
          -d linuxserver/deluge:latest
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop deluge; ${pkgs.podman}/bin/podman rm deluge";
      Restart = "always";
      User = "deluge";
      Group = "deluge";
    };
  };

  ## Jackett (Torrent indexer API) ##
  systemd.services.podman-jackett = {
    description = "Jackett indexer container";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name jackett \
          --network host \               # use host networking (exposes service directly on host)
          -e PUID=${PUID} -e PGID=${PGID} -e TZ=${TZ} \   # environment variables
          -v /etc/localtime:/etc/localtime:ro \           # pass host timezone file (read-only)
          -v ${rootDir}/downloads/torrent-blackhole:/downloads \  # torrent blackhole folder
          -v ${rootDir}/config/jackett:/config \          # Jackett config folder
          -d linuxserver/jackett:latest
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop jackett; ${pkgs.podman}/bin/podman rm jackett";
      Restart = "always";
      User = "jackett";
      Group = "jackett";
    };
  };

  ## NZBGet (Usenet downloader) ##
  systemd.services.podman-nzbget = {
    description = "NZBGet Usenet downloader container";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name nzbget \
          --network host \ 
          -e PUID=${PUID} -e PGID=${PGID} -e TZ=${TZ} \
          -v ${rootDir}/downloads:/downloads \    # downloads folder
          -v ${rootDir}/config/nzbget:/config \   # NZBGet config folder
          -d linuxserver/nzbget:latest
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop nzbget; ${pkgs.podman}/bin/podman rm nzbget";
      Restart = "always";
      User = "nzbget";
      Group = "nzbget";
    };
  };

  ## Sonarr (TV show manager) ##
  systemd.services.podman-sonarr = {
    description = "Sonarr TV manager container";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name sonarr \
          --network host \ 
          -e PUID=${PUID} -e PGID=${PGID} -e TZ=${TZ} \
          -v /etc/localtime:/etc/localtime:ro \   # pass host timezone info
          -v ${rootDir}/config/sonarr:/config \   # Sonarr config
          -v ${rootDir}/complete/tv:/tv \         # TV shows library folder
          -v ${rootDir}/downloads:/downloads \    # downloads folder
          -d linuxserver/sonarr:latest
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop sonarr; ${pkgs.podman}/bin/podman rm sonarr";
      Restart = "always";
      User = "sonarr";
      Group = "sonarr";
    };
  };

  ## Radarr (Movies manager) ##
  systemd.services.podman-radarr = {
    description = "Radarr movie manager container";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name radarr \
          --network host \ 
          -e PUID=${PUID} -e PGID=${PGID} -e TZ=${TZ} \
          -v /etc/localtime:/etc/localtime:ro \   # timezone info
          -v ${rootDir}/config/radarr:/config \   # Radarr config
          -v ${rootDir}/complete/movies:/movies \ # Movies library folder
          -v ${rootDir}/downloads:/downloads \    # downloads folder
          -d linuxserver/radarr:latest
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop radarr; ${pkgs.podman}/bin/podman rm radarr";
      Restart = "always";
      User = "radarr";
      Group = "radarr";
    };
  };

  ## Plex Media Server ##
  systemd.services.podman-plex = {
    description = "Plex Media Server container";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name plex-server \
          --network host \ 
          -e TZ=${TZ} \                              # timezone
          -v ${rootDir}/config/plex/db:/config \      # Plex database/config
          -v ${rootDir}/config/plex/transcode:/transcode \  # transcoding temp dir
          -v ${rootDir}/complete:/data \              # media library root (TV+movies)
          -d plexinc/pms-docker:latest
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop plex-server; ${pkgs.podman}/bin/podman rm plex-server";
      Restart = "always";
      User = "plex";
      Group = "plex";
    };
  };

  ## Bazarr (Subtitle downloader) ##
  systemd.services.podman-bazarr = {
    description = "Bazarr subtitles service container";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name bazarr \
          --network host \ 
          -e PUID=${PUID} -e PGID=${PGID} -e TZ=${TZ} -e UMASK_SET=022 \  # include UMASK
          -v ${rootDir}/config/bazarr:/config \    # Bazarr config
          -v ${rootDir}/complete/movies:/movies \  # Movies library
          -v ${rootDir}/complete/tv:/tv \          # TV shows library
          -d linuxserver/bazarr:latest
      '';
      ExecStop = "${pkgs.podman}/bin/podman stop bazarr; ${pkgs.podman}/bin/podman rm bazarr";
      Restart = "always";
      User = "bazarr";
      Group = "bazarr";
    };
  };

}

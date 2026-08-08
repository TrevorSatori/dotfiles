{ pkgs, ... }:

let
  # Network namespace bind settings (Gluetun replacement)
  bindToVpn = {
    NetworkNamespacePath = "/run/netns/mullvad";
    BindReadOnlyPaths = [ "/etc/resolv.conf" ];
    Requires = [ "vpn-namespace.service" ];
    After = [ "vpn-namespace.service" ];
  };

  # Common Systemd Sandboxing
  hardenedConfig = {
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    ProtectKernelTunables = true;
    ProtectControlGroups = true;
    CapabilityBoundingSet = [ "CAP_CHOWN" "CAP_SETUID" "CAP_SETGID" "CAP_FOWNER" ];
  };
in
{
  # qBittorrent
  services.qbittorrent = {
    enable = true;
    user = "media";
    group = "media";
    port = 8080;
  };
  systemd.services.qbittorrent.serviceConfig = hardenedConfig // bindToVpn // {
    ReadWritePaths = [ "/var/lib/qbittorrent" "/data/downloads" "/data/media" ];
  };

  # Sonarr
  services.sonarr = { enable = true; user = "media"; group = "media"; };
  systemd.services.sonarr.serviceConfig = hardenedConfig // bindToVpn // {
    ReadWritePaths = [ "/var/lib/sonarr" "/data/downloads" "/data/media" ];
  };

  # Radarr
  services.radarr = { enable = true; user = "media"; group = "media"; };
  systemd.services.radarr.serviceConfig = hardenedConfig // bindToVpn // {
    ReadWritePaths = [ "/var/lib/radarr" "/data/downloads" "/data/media" ];
  };

  # Lidarr
  services.lidarr = { enable = true; user = "media"; group = "media"; };
  systemd.services.lidarr.serviceConfig = hardenedConfig // bindToVpn // {
    ReadWritePaths = [ "/var/lib/lidarr" "/data/downloads" "/data/media" ];
  };

  # Prowlarr
  services.prowlarr = { enable = true; };
  systemd.services.prowlarr.serviceConfig = hardenedConfig // bindToVpn // {
    ReadWritePaths = [ "/var/lib/prowlarr" ];
  };
}

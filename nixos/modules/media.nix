{ pkgs, ... }:

let
  hardenedConfig = {
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    ProtectHome = true;
    ProtectKernelTunables = true;
  };
in
{
  # ---------------------------------------------------------------------------
  # Jellyfin (Media Streaming)
  # ---------------------------------------------------------------------------
  services.jellyfin = {
    enable = true;
    user = "media";
    group = "media";
  };
  # Grant Jellyfin user access to GPU nodes for QuickSync / VAAPI
  users.users.media.extraGroups = [ "video" "render" ];

  systemd.services.jellyfin.serviceConfig = hardenedConfig // {
    ReadWritePaths = [ "/var/lib/jellyfin" "/var/cache/jellyfin" "/data/media" ];
    DeviceAllow = [ "/dev/dri/renderD128 rwm" "/dev/dri/card0 rwm" ];
  };

  # ---------------------------------------------------------------------------
  # Immich (Photos & Video Backup)
  # ---------------------------------------------------------------------------
  services.immich = {
    enable = true;
    port = 2283;
    host = "0.0.0.0";
    mediaLocation = "/data/media/photos";
    
    # Enable hardware acceleration for machine learning & video transcoding
    accelerationDevices = [ "/dev/dri/renderD128" ];
  };
  users.users.immich.extraGroups = [ "video" "render" ];

  systemd.services.immich-server.serviceConfig = {
    NoNewPrivileges = true;
    ProtectSystem = "strict";
    ProtectHome = true;
  };

  # ---------------------------------------------------------------------------
  # Audiobookshelf (Audiobooks & Podcasts)
  # ---------------------------------------------------------------------------
  services.audiobookshelf = {
    enable = true;
    user = "media";
    group = "media";
    port = 13378;
  };
  systemd.services.audiobookshelf.serviceConfig = hardenedConfig // {
    ReadWritePaths = [ "/var/lib/audiobookshelf" "/data/media/audiobooks" ];
  };

  # ---------------------------------------------------------------------------
  # Komga (Comics & Manga)
  # ---------------------------------------------------------------------------
  services.komga = {
    enable = true;
    user = "media";
    group = "media";
    port = 25600;
  };
  systemd.services.komga.serviceConfig = hardenedConfig // {
    ReadWritePaths = [ "/var/lib/komga" "/data/media/comics" "/data/media/manga" ];
  };

  # ---------------------------------------------------------------------------
  # Calibre Server (E-books)
  # ---------------------------------------------------------------------------
  services.calibre-server = {
    enable = true;
    user = "media";
    group = "media";
    port = 8082;
    libraries = [ "/data/media/books" ];
  };
}

{ pkgs, lib, config, ... }:

{
  # ---------------------------------------------------------------------------
  # Host Identity & Core Networking
  # ---------------------------------------------------------------------------
  networking.hostName = "lo-pan";
  networking.networkmanager.enable = true;

  # Enable Flakes and modern CLI commands
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Timezone and Localization
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # ---------------------------------------------------------------------------
  # Hardware Acceleration (Intel Celeron QuickSync / VAAPI)
  # ---------------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver  # Modern VAAPI driver for Intel Gen 9+
      intel-vaapi-driver   # Fallback i965 driver
      libvdpau-va-gl
    ];
  };

  # ---------------------------------------------------------------------------
  # Users and Permissions (Shared Media UID/GID 1800)
  # ---------------------------------------------------------------------------
  users.groups.media.gid = 1800;
  users.users.media = {
    isSystemUser = true;
    group = "media";
    uid = 1800;
  };

  # Primary Admin User
  users.users.satori = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "render" ]; # video/render for GPU
    shell = pkgs.zsh;
    packages = with pkgs; [
      neovim
      git
      tmux
      htop
      curl
      wget
      ripgrep
      fd           # Modern, fast 'find' replacement
    ];
  };

  programs.zsh.enable = true;

  # System-wide Base Packages
  environment.systemPackages = with pkgs; [
    neovim
    git
    networkmanager
    wireguard-tools
    restic
  ];

  # ---------------------------------------------------------------------------
  # Restic Automated Backups
  # ---------------------------------------------------------------------------
  services.restic.backups.homelab = {
    repository = "/mnt/backups/restic"; # Change to S3/B2 or external drive as needed
    passwordFile = "/var/src/secrets/restic-password";
    initialize = true;
    paths = [
      "/var/lib"   # Automatically captures all app DBs (Jellyfin, Sonarr, Immich, etc.)
      "/etc/nixos" # Captures Nix configuration code
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 12"
    ];
  };

  # ---------------------------------------------------------------------------
  # Host Firewall
  # ---------------------------------------------------------------------------
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 3000 8096 13378 1080 25600 8384 22000 ];
    allowedUDPPorts = [ 51820 22000 21027 ];
  };

  system.stateVersion = "24.11";
}

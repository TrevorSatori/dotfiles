{ pkgs, ... }:

{
  # FreshRSS
  services.freshrss = {
    enable = true;
    baseUrl = "https://freshrss.lo-pan.com";
    defaultUser = "satori";
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "satori";
    dataDir = "/var/lib/syncthing";
    overrideDevices = false;
    overrideFolders = false;
  };

  # Homepage Dashboard
  services.homepage-dashboard = {
    enable = true;
    listenPort = 3000;
  };
}

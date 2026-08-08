{ pkgs, ... }:

{
  services.caddy = {
    enable = true;

    # Compiles Caddy with the Cloudflare DNS plugin
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/cloudflare@v1.0.1" ];
      hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update on first rebuild
    };

    # Inline Caddyfile matching your exact configuration
    configFile = pkgs.writeText "Caddyfile" ''
      {
        skip_install_trust
      }

      # --- Global TLS Snippet ---
      (cf_tls) {
        tls {
          dns cloudflare {env.CLOUDFLARE_API_TOKEN}
        }
      }

      wg-admin.lo-pan.com {
        import cf_tls
        reverse_proxy 10.8.0.1:51821
      }

      # --- Media & Books ---

      freshrss.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:1080
      }

      immich.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:2283
      }

      jellyfin.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:8096 {
          header_up X-Forwarded-Proto https
          header_up X-Forwarded-Host {host}
        }
      }

      audiobookshelf.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:13378
      }

      komga.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:25600
      }

      calibre.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:8082
      }

      # --- Downloads & Automation ---

      sonarr.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:8989
      }

      radarr.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:7878
      }

      lidarr.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:8686
      }

      prowlarr.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:9696
      }

      qbittorrent.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:8080
      }

      # --- Management & Tools ---

      portainer.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:9000
      }

      syncthing.lo-pan.com {
        import cf_tls
        reverse_proxy localhost:8384
      }
    '';
  };

  # Load Cloudflare API token securely
  systemd.services.caddy.serviceConfig.EnvironmentFile = "/var/src/secrets/caddy.env";
}

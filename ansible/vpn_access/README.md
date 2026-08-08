# 🚀 WireGuard & Homelab Architecture

This repository automates the deployment of a secure WireGuard VPN relay on a DigitalOcean VPS (`PorkChopExpress`) using Ansible and integrates it with a local Home Server reverse-proxy setup.

---

## 🏗️ Architecture Overview

```text
┌─────────────────────────────────────────────────────────┐
│                    PUBLIC INTERNET                      │
└────────────────────────────┬────────────────────────────┘
                             │ WireGuard Tunnel Handshake
                             │ (UDP 51820)
                             ▼
 ┌───────────────────────────────────────────────────────┐
 │               DigitalOcean VPS (Relay)                │
 │  * WireGuard Interface (10.8.0.1)                     │
 │  * wg-easy Web UI (Bound to 127.0.0.1:51821 ONLY)    │
 └───────────────────────────┬───────────────────────────┘
                             │
                             │ Encrypted WireGuard Tunnel
                             │ (10.8.0.0/24 Private Network)
                             ▼
 ┌───────────────────────────────────────────────────────┐
 │                  Local Home Server                    │
 │  * IP: 10.8.0.2 (Joined to VPN)                       │
 │  * Caddy Reverse Proxy (Handles SSL via Cloudflare)  │
 │  * Internal Apps (Jellyfin, Sonarr, Radarr, etc.)     │
 └───────────────────────────┘

💡 Why Keep Caddy on the Local Home Server?Instead of running a web server/reverse proxy in the cloud, Caddy is kept on the local home server for three reasons:🔒 Zero-Trust Security: The WireGuard admin interface (wg-easy) is bound strictly to 127.0.0.1 on the VPS and is never exposed to the public internet.🌐 Split-Horizon DNS: Traffic destined for *.example.com resolves directly to 10.8.0.2. Unless a device is actively connected to the WireGuard VPN tunnel, the admin page and homelab applications are completely invisible and unreachable from the public internet.🔑 Centralized TLS Management: Caddy automatically provisions and manages wildcard SSL certificates via Cloudflare DNS-01 challenges locally, keeping API tokens and reverse-proxy logic inside your local network.☁️ Cloudflare DNS ConfigurationTo support split-horizon routing, set up your DNS records in Cloudflare as follows:TypeNameContent / TargetProxy StatusDescriptionAvpn.example.com107.170.59.97DNS Only (Gray Cloud)Public IP of DigitalOcean VPS used for WireGuard tunnel handshakes.A*.example.com10.8.0.2DNS Only - Reserved IPWildcard record pointing all subdomains (wg-admin, jellyfin, etc.) to your local Home Server's private VPN IP.Note: Cloudflare cannot proxy UDP traffic or internal RFC1918 IPs (10.x.x.x), so both records must be set to "DNS Only" (Gray Cloud).🔑 First-Time Setup & Seeding Clients (SSH Tunneling)Because wg-easy port 51821 is locked to 127.0.0.1 from day one, you cannot access the web UI publicly to create your initial VPN configs. We solve this "chicken-and-egg" bootstrap problem using an SSH Local Port Forward.Step 1: Deploy via AnsibleRun the playbook on your server or local machine:Bashansible-playbook setup_wireguard.yml

Step 2: Establish an SSH TunnelFrom your laptop or workstation, open an SSH tunnel to forward port 51821:Bashssh -L 51821:127.0.0.1:51821 root@vpn.example.com
(Keep this terminal window open!)Step 3: Seed Your Initial ProfilesOpen your local browser and navigate to:Plaintexthttp://localhost:51821
Create a peer for your Home Server, download its .conf profile, and import it onto the home server so it joins the VPN network as 10.8.0.2.Create peers for your mobile devices/laptops and scan the QR codes.Close the SSH terminal session.🌐 Caddyfile Configuration (Home Server)Add the wg-admin.example.com site block to your Caddyfile on your local home server:Code snippet# --- Global TLS Snippet ---
(cf_tls) {
	tls {
		dns cloudflare {env.CLOUDFLARE_API_TOKEN}
	}
}

# --- WireGuard Web UI (Routed over internal VPN) ---
wg-admin.example.com {
	import cf_tls
	reverse_proxy 10.8.0.1:51821
}

# --- Media & Automation Services ---
freshrss.example.com {
	import cf_tls
	reverse_proxy localhost:1080
}

jellyfin.example.com {
	import cf_tls
	reverse_proxy localhost:8096 {
		header_up X-Forwarded-Proto https
		header_up X-Forwarded-Host {host}
	}
}
Reload Caddy once added:Bashcaddy reload
🛠️ Accessing Services Post-SetupWireGuard Client App: Points directly to vpn.example.com:51820 (UDP public endpoint).WireGuard Admin Dashboard: Connect to the VPN and open https://wg-admin.example.com (HTTPS via Caddy over private network).

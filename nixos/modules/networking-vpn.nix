{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # 1. Point-to-Point DigitalOcean Remote WireGuard Tunnel
  # ---------------------------------------------------------------------------
  networking.wireguard.interfaces.wg-remote = {
    ips = [ "10.8.0.2/32" "fdcc:ad94:bacf:61a4::cafe:2/128" ];
    privateKeyFile = "/var/src/secrets/wg-remote-private.key";

    peers = [{
      publicKey = "<YOUR_DIGITALOCEAN_PUBLIC_KEY>";
      allowedIPs = [ "10.8.0.0/24" ];
      endpoint = "vpn.lo-pan.com:51820";
      persistentKeepalive = 25;
    }];
  };

  # ---------------------------------------------------------------------------
  # 2. Maximum Isolation Mullvad VPN Network Namespace (Gluetun Replacement)
  # ---------------------------------------------------------------------------
  systemd.services.vpn-namespace = {
    description = "Isolated Mullvad VPN Network Namespace";
    before = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ iproute2 wireguard-tools iptables ];
    script = ''
      # Create namespace and enable loopback
      ip netns add mullvad || true
      ip netns exec mullvad ip link set dev lo up

      # Create wireguard interface in host, move to namespace
      ip link add wg-mullvad type wireguard
      ip link set wg-mullvad netns mullvad

      # Configure WireGuard inside netns
      ip netns exec mullvad wg setconf wg-mullvad /var/src/secrets/mullvad-wg.conf
      ip netns exec mullvad ip address add <MULLVAD_ADDRESS>/32 dev wg-mullvad
      ip netns exec mullvad ip link set dev wg-mullvad up
      ip netns exec mullvad ip route add default dev wg-mullvad
    '';
    postStop = ''
      ip netns del mullvad || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}

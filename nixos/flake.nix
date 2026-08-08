{
  description = "Homelab NixOS Flake Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations.lo-pan = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        ./modules/caddy.nix
        ./modules/arr-stack.nix
        ./modules/media.nix
        ./modules/utilities.nix
        ./modules/networking-vpn.nix
      ];
    };
  };
}

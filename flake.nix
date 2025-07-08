{
  description = "NixOS configuration for Raspberry Pi 4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = { self, nixpkgs, raspberry-pi-nix }:
    let
      system = "aarch64-linux";
    in {
      nixosConfigurations = {
        rpi4 = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            raspberry-pi-nix.nixosModules.raspberry-pi
            raspberry-pi-nix.nixosModules.sd-image
            ./configuration.nix
          ];
        };
      };
    };
}

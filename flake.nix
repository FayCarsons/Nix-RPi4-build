{
    description = "NixOS config for RPi 4";
    inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    };

    outputs = { self, nixpkgs, nixos-hardware }: {
      nixosConfigurations.raspberry-pi = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          nixos-hardware.nixosModules.raspberry-pi-4
          ./configuration.nix
        ];
      };
    };
}

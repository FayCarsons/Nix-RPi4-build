{
  description = "NixOS configuration for Raspberry Pi 4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.raspberry-pi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # This is what the article author found was necessary!
        nixos-hardware.nixosModules.raspberry-pi-4
        ./configuration.nix
      ];
    };
  };
}

{
  description = "NixOS for Raspberry Pi 4";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    raspberry-pi-nix = {
      url = "github:nix-community/raspberry-pi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, raspberry-pi-nix }:
    {
      nixosConfigurations.kiggymedia = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inputs = { inherit raspberry-pi-nix; }; };
        modules = [
          raspberry-pi-nix.nixosModules.raspberry-pi
          ./default.nix
        ];
      };
    };
}

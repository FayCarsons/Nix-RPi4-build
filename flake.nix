{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";  # Use stable, not unstable
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";
    in {
      nixosConfigurations.kiggymedia = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
        ];
      };
    };
}

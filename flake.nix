{
  description = "NixOS for Raspberry Pi 4 with raspberry-pi-nix";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };
  
  # Add binary cache configuration
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCim8cyXW6WPI711V+Ji8vr9wTT5dBRdg=" ];
  };
  
  outputs = { self, nixpkgs, raspberry-pi-nix }: 
  let
    inherit (nixpkgs.lib) nixosSystem;
    
    basic-config = { pkgs, lib, ... }: {
      # Pi 4 board configuration - this is the key setting!
      raspberry-pi-nix.board = "bcm2711";
      
      # Serial console parameters
      boot.kernelParams = [
        "console=ttyAMA0,115200"
        "console=tty1"
      ];
      
      # Basic networking
      networking = {
        hostName = "kiggymedia";
        useDHCP = false;
        interfaces = {
          eth0.useDHCP = true;
        };
      };

      # Enable SSH with root login
      services.openssh = {
        enable = true;
        settings.PermitRootLogin = "yes";
      };

      # Root user with SSH key
      users.users.root = {
        initialPassword = "root";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpeoFztO2Jhgk0dIfV3s41H8qFCmy8YTBT1idaiD3Mm faycarsons23@gmail.com"
        ];
      };

      # Hardware support
      hardware = {
        enableRedistributableFirmware = true;
        bluetooth.enable = false; # Keep it simple initially
      };

      # Minimal packages
      environment.systemPackages = with pkgs; [
        vim
        htop
      ];

      # System version
      system.stateVersion = "24.11";
    };
  in {
    nixosConfigurations = {
      kiggymedia = nixosSystem {
        system = "aarch64-linux";
        modules = [
          raspberry-pi-nix.nixosModules.raspberry-pi
          basic-config
        ];
      };
    };
  };
}

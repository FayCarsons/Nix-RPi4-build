{
  description = "Minimal NixOS for Raspberry Pi 4 using standard approach";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };
  
  # Add binary cache configuration for faster builds
  nixConfig = {
    extra-substituters = [ "https://nix-community.cachix.org" ];
    extra-trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCim8cyXW6WPI711V+Ji8vr9wTT5dBRdg=" ];
  };
  
  outputs = { self, nixpkgs, nixos-hardware }: {
    nixosConfigurations.kiggymedia = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        # Import standard SD image module
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        # Import Pi 4 hardware support
        nixos-hardware.nixosModules.raspberry-pi-4
        
        ({ pkgs, lib, modulesPath, ... }: {
          # Serial console parameters for debugging
          boot.kernelParams = [
            "console=ttyAMA0,115200"
            "console=tty1"
          ];
          
          # Disable GRUB (Pi uses different bootloader)
          boot.loader.grub.enable = false;
          boot.loader.generic-extlinux-compatible.enable = true;

          # Basic networking
          networking = {
            hostName = "kiggymedia";
            useDHCP = false;
            interfaces.eth0.useDHCP = true;
          };

          # Enable SSH with root login for initial setup
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
          hardware.enableRedistributableFirmware = true;
          
          # Disable ZFS to avoid long build times
          boot.supportedFilesystems = lib.mkForce [ "ext4" "vfat" ];

          # Minimal packages
          environment.systemPackages = with pkgs; [
            vim
            htop
          ];

          # Disable compression for faster builds  
          sdImage.compressImage = false;

          # System version
          system.stateVersion = "24.11";
        })
      ];
    };
  };
}

{
  description = "Custom NixOS Raspberry Pi image with SSH, WiFi, and proper boot partition";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.raspberrypi = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ({ config, pkgs, ... }: {
          # Large boot partition (1GB)
          sdImage = {
            firmwareSize = 1024; # MB
            populateFirmwareCommands = "";
            populateRootCommands = "";
          };

          services.xserver.enable = false;
          hardware.pulseaudio.enable = false;
          hardware.bluetooth.enable = false;

          boot.loader.grub.enable = false;
          boot.loader.generic-extlinux-compatible.enable = true;

          services.openssh = {
            enable = true;
            settings = {
              PasswordAuthentication = true;
              PermitRootLogin = "yes";
              KbdInteractiveAuthentication = true;
            };
            openFirewall = true;
          };

          networking = {
            hostName = "raspberrypi";
            wireless = {
              enable = true;
              networks."FiOS-WTPA7".psk = "munch386wire040jag";
            };

            networkmanager.enable = false;
          };

          # Create user account
          users.users.fay = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
            initialPassword = "kiggy";
            
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpeoFztO2Jhgk0dIfV3s41H8qFCmy8YTBT1idaiD3Mm faycarsons23@gmail.com"             
            ];
          };

          environment.systemPackages = with pkgs; [
            vim
            git
            htop
            curl
            wget
            rsync
            tmux
          ];

          # Enable flakes and new nix commands
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            auto-optimise-store = true;
            # Optimize for limited resources
            max-jobs = 2;
            cores = 0; # Use all available cores per job
          };

          # More aggressive garbage collection for headless
          nix.gc = {
            automatic = true;
            dates = "daily";
            options = "--delete-older-than 7d";
          };

          # Set timezone
          time.timeZone = "America/New_York"; # Change to your timezone

          # Enable hardware-specific optimizations
          hardware.enableRedistributableFirmware = true;
          
          services.journald.extraConfig = ''
            SystemMaxUse=100M
            MaxRetentionSec=1month
          '';
          
          boot.kernelParams = [ "console=serial0,115200" "console=tty1" ];
          
          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ 22 ]; # SSH
          };

          system.stateVersion = "24.11";
        })
      ];
    };

    # Make the SD card image easily buildable
    packages.aarch64-linux.default = self.nixosConfigurations.raspberrypi.config.system.build.sdImage;

    # For convenience, also expose it for other architectures during cross-compilation
    packages.x86_64-linux.default = self.nixosConfigurations.raspberrypi.config.system.build.sdImage;
    packages.aarch64-darwin.default = self.nixosConfigurations.raspberrypi.config.system.build.sdImage;
  };
}

{
  description = "Raspberry Pi 4 NixOS Media Server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations.kiggymedia = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ({ config, pkgs, lib, modulesPath, ... }: {
          imports = [
            # Use the SD card image module
            "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
          ];

          # Essential: disable ZFS to avoid build issues
          boot.supportedFilesystems.zfs = lib.mkForce false;

          # Serial console configuration for headless boot
          boot = {
            kernelParams = [
              "console=ttyAMA0,115200"
              "console=tty1"
              "8250.nr_uarts=1"
            ];
            
            # Enable serial console in bootloader
            loader.raspberryPi.firmwareConfig = ''
              enable_uart=1
              dtparam=audio=on
            '';
          };

          # Enable serial console service
          systemd.services."serial-getty@ttyAMA0" = {
            enable = true;
            wantedBy = [ "getty.target" ];
            serviceConfig.Restart = "always";
          };

          # Basic networking
          networking = {
            hostName = "kiggymedia";
            networkmanager.enable = true;
            networkmanager.wifi.powersave = false;
          };

          # SSH access
          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "yes";
              PasswordAuthentication = true;
            };
          };

          # Create your user instead of using root
          users.users.fay = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" ];
            initialPassword = "changeme";
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpeoFztO2Jhgk0dIfV3s41H8qFCmy8YTBT1idaiD3Mm faycarsons23@gmail.com"
            ];
          };

          # Allow passwordless sudo
          security.sudo.wheelNeedsPassword = false;

          # Enable firmware
          hardware.enableRedistributableFirmware = true;

          # Enable binary cache and flakes
          nix = {

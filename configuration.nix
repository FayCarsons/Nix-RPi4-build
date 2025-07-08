{ config, pkgs, lib, ... }: {
  # Remove the sd-card import - the flake handles this now
  # imports = [
  #   "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  # ];

  # Pi 4 specific configuration
  hardware.raspberry-pi.config = {
    all = {
      options = {
        # Enable serial console
        enable_uart = {
          enable = true;
          value = true;
        };
        # Use 64-bit mode
        arm_64bit = {
          enable = true;
          value = true;
        };
      };
    };
  };

  # Boot configuration - let raspberry-pi-nix handle this
  boot.supportedFilesystems.zfs = lib.mkForce false;
  
  # Serial console for debugging
  boot.kernelParams = [ 
    "console=ttyAMA0,115200" 
    "console=tty0" 
    "loglevel=7"
  ];
  
  # SD image settings
  sdImage.compressImage = false;
  
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;
  
  networking = {
    hostName = "media-server";
    networkmanager.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
  
  services.jellyfin.enable = true;
  services.openssh.enable = true;
  
  users.users.pi = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    initialHashedPassword = "";
  };
  
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.11";
}

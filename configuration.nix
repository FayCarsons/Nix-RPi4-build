{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  boot.supportedFilesystems.zfs = lib.mkForce false;
  boot.kernelParams = [ 
    "console=tty0"
    "console=ttyAMA0,115200"
    "console=ttyS0,115200"
    "loglevel=7"
    "earlyprintk"
    "debug"
    "ignore_loglevel"
  ]; 

  sdImage.compressImage = false;
  
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];
  
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;
  
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };
  
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
  system.stateVersion = "24.05";
}

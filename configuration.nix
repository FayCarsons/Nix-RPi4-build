{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    # This was the missing piece!
  ];

  # necessary
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_6;

  boot.supportedFilesystems.zfs = lib.mkForce false;
  sdImage.compressImage = false;
  
  # The crucial overlay from the article
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];
  
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;
  
  networking = {
    hostName = "media-server";
    dhcpcd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
  
  services.jellyfin.enable = true;
  services.openssh.enable = true;
  
  users.users.pi = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    initialHashedPassword = "";
  };
  
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";
}

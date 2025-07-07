{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    # This was the missing piece!
  ];

  # The author found this was NECESSARY despite community feedback
  # nixos-hardware.nixosModules.raspberry-pi-4 needs to be in the flake

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

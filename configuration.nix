{ config, pkgs, lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  # Essential Pi settings from the article
  boot.supportedFilesystems.zfs = lib.mkForce false;
  sdImage.compressImage = false;
  
  nixpkgs = {
    hostPlatform = "aarch64-linux";
    config.allowUnfree = true;
    overlays = [
      (final: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // {allowMissing = true;});
      })
    ];
  };

  networking = {
    hostName = "raspberry-pi";
    dhcpcd.enable = true;  # Simple networking instead of NetworkManager
  };

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    vim
    git
    libraspberrypi
    raspberrypi-eeprom
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };

  users.users.pi = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    initialHashedPassword = "";
  };

  security.sudo.wheelNeedsPassword = false;
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05";
}

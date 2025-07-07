{ config, pkgs, lib, ... }: {
# Critical Disable ZFS to save build time
  boot.supportedFilesystems.zfs = lib.mkForce false;
  # Workaround for missing kernel modules
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // {allowMissing = true;});
    })
  ];
  
  nixpkgs.hostPlatform = "aarch64-linux";
  nixpkgs.config.allowUnfree = true;
  
  # Basic system configuration
  networking.hostName = "raspberry-pi";
  time.timeZone = "America/New_York";  # Adjust as needed
  
  # Essential packages for Pi
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
    vim
    git
  ];
  
  # Enable firmware
  hardware.enableRedistributableFirmware = true;
  
  # Create your user (replace with your preferred username)
  users.users.pi = {
    isNormalUser = true;
    extraGroups = ["wheel" "networkmanager"];
    # Set initial password to empty (you'll set it on first boot)
    initialHashedPassword = "";
  };
  
  # Allow passwordless sudo
  security.sudo.wheelNeedsPassword = false;
  
  # Enable SSH
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
  
  # Enable NetworkManager for easier WiFi setup
  networking.networkmanager.enable = true;
  
  system.stateVersion = "24.05";
}

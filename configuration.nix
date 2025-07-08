# configuration.nix - Simple Pi 4 config for nixos-generators
{ pkgs, lib, ... }:

{

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;
    
    kernelParams = [
      "console=ttyAMA0,115200"
      "console=tty1"
    ];
    
    # Essential Pi 4 modules
    initrd.availableKernelModules = [
      "pcie_brcmstb"
      "reset-raspberrypi" 
      "usb_storage"
      "usbhid"
      "vc4"
    ];
    supportedFilesystems = lib.mkForce [ "ext4" "vfat" ];
  };

  # Basic networking
  networking = {
    hostName = "kiggymedia";
    useDHCP = false;
    interfaces.eth0.useDHCP = true;
  };

  # SSH access
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # Root user
  users.users.root = {
    initialPassword = "root";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpeoFztO2Jhgk0dIfV3s41H8qFCmy8YTBT1idaiD3Mm faycarsons23@gmail.com"
    ];
  };

  # Hardware support
  hardware.enableRedistributableFirmware = true;

  # Minimal packages
  environment.systemPackages = with pkgs; [
    vim
    htop
  ];

  system.stateVersion = "24.11";
}

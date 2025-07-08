# configuration.nix (rename your file to this)
{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./disks.nix
  ];

  boot = {
    loader = {
      grub.enable = false;
    };

    kernelParams = [
      "console=tty1"
      "console=serial0,115200n8"
    ];

    kernelPackages = pkgs.linuxPackagesFor pkgs.rpi-kernels.v6_12_17.bcm2711;
    
    initrd.availableKernelModules = [
      "pcie_brcmstb"     # required for the pcie bus to work
      "reset-raspberrypi" # required for vl805 firmware to load
      "usb_storage"
      "usbhid"
      "vc4"
    ];
  };

  # Networking
  networking = {
    hostName = "kiggymedia";
    useDHCP = false;
    interfaces = {
      eth0.useDHCP = true;
      wlan0.useDHCP = true;
    };
    wireless = {
      enable = true;
      networks = {
        "FiOS-WTPA7" = {
          psk = "munch386wire040jag";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    htop
  ];

  hardware.enableRedistributableFirmware = true;

  nixpkgs = {
    hostPlatform = "aarch64-linux";
    overlays = [ inputs.raspberry-pi-nix.overlays.core ];
  };

  raspberry-pi = {
    loader.enable = true;
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  users.users = {
    root = {
      initialPassword = "root";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpeoFztO2Jhgk0dIfV3s41H8qFCmy8YTBT1idaiD3Mm faycarsons23@gmail.com"
      ];
    };
  };

  system = {
    stateVersion = "24.11";
  };
}

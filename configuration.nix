# configuration.nix - Based on working 2025 setup
{ lib, pkgs, modulesPath, ... }: {
  imports = [
    # This is the key - use the stock sd-image module, not nixos-hardware
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  # System basics
  system.stateVersion = "24.11";
  time.timeZone = "America/New_York";

  # User setup
  users.users.root = {
    initialPassword = "root";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpeoFztO2Jhgk0dIfV3s41H8qFCmy8YTBT1idaiD3Mm faycarsons23@gmail.com"
    ];
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  # Networking - use simple wpa_supplicant instead of NetworkManager
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

  # File systems (this gets set up by the sd-image module)
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  # Serial console configuration
  boot.kernelParams = [ 
    "console=serial0,115200" 
    "console=tty1"
    "debug"
    "ignore_loglevel"
  ];

  # Nix settings for building/caching
  nix.settings = {
    trusted-users = [ "root" ];
    substituters = [ 
      "https://cache.nixos.org"
      "https://nix-community.cachix.org" 
    ];
    trusted-public-keys = [ 
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" 
    ];
  };

  # Workaround for missing kernel modules (common Pi issue)
  nixpkgs = {
    hostPlatform = lib.mkDefault "aarch64-linux";
    config = {
      allowUnfree = true;
    };
    overlays = [
      # Fix for missing modules
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // {allowMissing = true;});
      })
    ];
  };

  # Minimal packages
  environment.systemPackages = with pkgs; [
    vim
    htop
    libraspberrypi  # Pi-specific tools
    raspberrypi-eeprom  # For firmware updates
  ];

  # Disable things that cause build issues
  documentation.enable = false;
  documentation.nixos.enable = false;

  # SD image specific settings
  sdImage = {
    compressImage = false;  # Faster builds
  };
}

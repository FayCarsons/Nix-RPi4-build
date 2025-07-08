{ pkgs, ... }: {
  system.stateVersion = "24.05";
  
  # Basic system settings
  time.timeZone = "America/New_York";
  users.users.root = {
    initialPassword = "root";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpeoFztO2Jhgk0dIfV3s41H8qFCmy8YTBT1idaiD3Mm faycarsons23@gmail.com"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
  
  # Networking configuration
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

  # Raspberry Pi 4 board configuration
  raspberry-pi-nix.board = "bcm2711";
  
  hardware = {
    raspberry-pi = {
      config = {
        all = {
          base-dt-params = {
            BOOT_UART = {
              value = 1;
              enable = true;
            };
            uart_2ndstage = {
              value = 1;
              enable = true;
            };
          };
          dt-overlays = {
            disable-bt = {
              enable = true;
              params = { };
            };
          };
          # Using default direct kernel boot (no u-boot)
        };
      };
    };
  };

  # Enhanced serial console and debug configuration
  boot.kernelParams = [ 
    "console=serial0,115200" 
    "console=tty1"
    "debug"
    "ignore_loglevel"
    "earlycon=uart8250,mmio32,0xfe215040"
    "loglevel=7"
    "earlyprintk"
  ];

  # Disable all graphics/desktop stuff
  services.xserver.enable = false;
  hardware.opengl.enable = false;
  
  # Disable audio entirely
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = false;
  services.pipewire.enable = false;
  
  # Minimal packages
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    screen  # Useful for serial console sessions
  ];

  # Reduce system size and disable unnecessary features
  documentation.enable = false;
  documentation.nixos.enable = false;
  
  # Disable unnecessary services
  services.udisks2.enable = false;
  programs.command-not-found.enable = false;
  xdg.autostart.enable = false;
  xdg.mime.enable = false;
  xdg.icons.enable = false;
  xdg.sounds.enable = false;
  
  # Disable bluetooth completely
  hardware.bluetooth.enable = false;
  
  # Minimal locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
}

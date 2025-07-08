{
  fileSystems = {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=512M"
        "mode=755"
      ];
    };
    "01-/persistent" = {
      mountPoint = "/persistent";
      device = "/dev/disk/by-label/NIXOS";
      fsType = "ext4";
      options = [
        "data=journal"
        "noatime"
      ];
      neededForBoot = true;
    };
    "02-/nix" = {
      mountPoint = "/nix";
      device = "/persistent/nix";
      options = [ "bind" ];
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS-BOOT";
      fsType = "vfat";
    };
  };
}


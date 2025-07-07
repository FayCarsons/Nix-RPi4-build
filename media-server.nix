{ config, pkgs, lib, ... }:

let 
  mediaDir = "/media";
  downloadDir = "/media/downloads";
  mediaUser = "media-server";
  mediaGroup = "media-server";
  mediaUID = 1000;
  mediaGID = 1000;
in 
{
  system.activationScripts.mediaDirectories = ''
    mkdir -p ${mediaDir}/{movies,tv,downloads/{complete, incomplete}}
    chown -R ${mediaUser}:${mediaGroup} ${mediaDir}
    chmod -R 775 ${mediaDir}
  '';

  users.users.${mediaUser} = {
    isSystemUser = true;
    uid = mediaUID;
    group = mediaGroup;
    home = "/var/lib/media-server";
    createHome = true;
  };

  users.groups.${mediaGroup} = {
    gid = mediaGID;
  };

  services.qbittorrent = {
    enable = true;
    user = mediaUser;
    group = mediaGroup;
    port = 8080;
    openFirewall = true;
    dataDir = "/var/lib/qbittorrent";
    configDir = "/var/lib/qbittorrent/.config";
  };

  # Jellyfin
  services.jellyfin = {
    enable = true;
    user = mediaUser;
    group = mediaGroup;
    openFirewall = true;
    dataDir = "/var/lib/jellyfin";
    configDir = "/var/lib/jellyfin/config";
    cacheDir = "/var/lib/jellyfin/cache";
    logDir = "/var/log/jellyfin";
  };

  # Sonarr (TV Shows)
  services.sonarr = {
    enable = true;
    user = mediaUser;
    group = mediaGroup;
    openFirewall = true;
    dataDir = "/var/lib/sonarr";
  };

  # Radarr (Movies)
  services.radarr = {
    enable = true;
    user = mediaUser;
    group = mediaGroup;
    openFirewall = true;
    dataDir = "/var/lib/radarr";
  };

  # Prowlarr (Indexer Management)
  services.prowlarr = {
    enable = true;
    user = mediaUser;
    group = mediaGroup;
    openFirewall = true;
  };

  # Bazarr (Subtitles) - Optional
  services.bazarr = {
    enable = true;
    user = mediaUser;
    group = mediaGroup;
    openFirewall = true;
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "media.local" = {
        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8096";
            proxyWebsockets = true;
          };
          "/qbit/" = {
            proxyPass = "http://127.0.0.1:8080/";
            extraConfig = ''
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
          "/sonarr/" = {
            proxyPass = "http://127.0.0.1:8989/sonarr";
            extraConfig = ''
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $schema;
            '';
          };
          "/radarr/" = {
            proxyPass = "http://127.0.0.1:7878/radarr";
            extraConfig = ''
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_redirect off;
            '';
          };
          "/prowlarr/" = {
            proxyPass = "http://127.0.0.1:9696/prowlarr";
            extraConfig = ''
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Host $host;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_redirect off;
            '';
          };
        };
      };
    };
  };

  hardware.raspberry-pi."4" = {
    fkms-3d.enable = true;
    audio.enable = true;
  };
}

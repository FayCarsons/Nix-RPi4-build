#!/usr/bin/env zsh

colima start

# Run the build commands inside the container
docker run -it --privileged --platform linux/arm64 \
  -v $(pwd):/workspace \
  nixos/nix:latest bash -c '
    cd /workspace

    # Configure nix inside the container
    confPath=/etc/nix/nix.conf
    echo "extra-platforms = aarch64-linux" >> $confPath
    echo "extra-sandbox-paths = /proc/sys/fs/binfmt_misc" >> $confPath  
    echo "experimental-features = nix-command flakes" >> $confPath
    
    # Trust the git repo
    git config --global --add safe.directory /workspace
    
    # Build the image
    nix build .#nixosConfigurations.pi.config.system.build.sdImage
'

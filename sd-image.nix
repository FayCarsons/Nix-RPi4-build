# Save as sd-image.nix
{ ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];
  
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFpeoFztO2Jhgk0dIfV3s41H8qFCmy8YTBT1idaiD3Mm faycarsons23@gmail.com"
  ];
}

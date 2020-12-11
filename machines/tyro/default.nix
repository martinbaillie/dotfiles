# Tyro - $WORK MacBook Pro.
# NOTE: I now only use the host macOS for video calls.
# Everything else is in a NixOS VM. SEE: ../parasite
{ config, pkgs, lib, ... }: {
  imports = [
    ../../.

    <modules/desktop>

    <modules/term>
    <modules/term/zsh.nix>
  ];

  nix = {
    # $ sysctl -n hw.ncpu
    maxJobs = 4;
    buildCores = 4;
  };

  my = {
    username = config.my.secrets.work_username;
    email = config.my.secrets.work_email;
    packages = with pkgs; [ ];
    brews = [ ];
    casks = [ "vmware-fusion" "amazon-chime" ];
  };
}

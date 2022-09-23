# VMWare-based NixOS VM for running a Docker daemon on macOS/Apple Silicon host.
{ config, lib, pkgs, ... }:

{
  # Machine identity.
  networking.hostName = "parasite";

  # Parasite only gets half of what its host has.
  nix.settings = rec {
    cores = 2;
    max-jobs = cores;
  };

  # Enable VMWare's guest additions.
  virtualisation.vmware.guest.enable = true;

  # Virtualisation fixes.
  boot = {
    initrd = {
      # Remove fsck check from startup.
      checkJournalingFS = false;
    };

    # Kernel tuning for virtualisation.
    kernelParams = [ "mitigations=off" ];
  };

  # We'll let the host handle this.
  powerManagement.enable = false;

  # Replace ntpd by timesyncd for more accurate virtualisation alignment.
  services.timesyncd.enable = true;

  # Docker.
  services.docker.enable = true;

  fileSystems."/shared" = {
    device = ".host:/shared";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [ "nofail,allow_other" ];
  };
}

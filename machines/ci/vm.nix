{ config, lib, pkgs, ... }: {
  boot.kernelPackages = pkgs.linuxPackages_latest;
  virtualisation = {
    cores = 2;
    memorySize = "1024M";
  };
  imports = [ ./. ];
}

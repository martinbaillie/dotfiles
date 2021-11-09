{ config, lib, pkgs, ... }:

{
  boot = {
    initrd.availableKernelModules =
      [ "xhci_pci" "ahci" "ehci_pci" "usb_storage" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-amd" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d6323ee5-8989-4d3b-9d8d-89bdc8511c8e";
    fsType = "ext4";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/ac3555dc-d272-42e5-ac57-19456d7b141d"; }];
}

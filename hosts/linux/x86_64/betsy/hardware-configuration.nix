{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules =
    [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/d9249a3c-8751-4af6-9ec3-268b05868757";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6557-3997";
    fsType = "vfat";
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/1831035a-d817-4ecb-8cd5-be848e55b01f"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

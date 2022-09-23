# Defaults across all my NixOS hosts.
{ inputs, config, lib, pkgs, options, ... }:

with lib;
with lib.my; {
  system = {
    # NixOS release to track state compatibility against.
    # Pair this with home-manager.
    stateVersion =
      config.home-manager.users.${config.user.name}.home.stateVersion;

    # Let `nixos-version --json` know about the Git revision of this flake.
    configurationRevision = with inputs; mkIf (self ? rev) self.rev;
  };

  nix = {
    # Automatically detects files in the store that have identical contents.
    settings.auto-optimise-store = true;

    gc = {
      # Automatically run the Nix garbage collector daily.
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };
  };

  # Needs must.
  nixpkgs.config.allowUnfree = true;

  # Boot and console.
  boot = {
    # Use the latest Linux kernel.
    kernelPackages = mkDefault pkgs.linuxPackages_5_10;

    # Cattle not pets.
    tmpOnTmpfs = true;

    # Kernel.
    kernelModules = [ "tcp_bbr" ];
    kernel.sysctl = {
      # Bufferbloat mitigations + slight improvements in throughput and latency.
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      # Fast Open is a TCP extension that reduces network latency by packing
      # data in the sender’s initial TCP SYN.
      # NOTE: Setting 3 = enable for both incoming and outgoing connections.
      "net.ipv4.tcp_fastopen" = 3;
    };
  };

  console.keyMap = "us";

  # Fix early console display.
  hardware.video.hidpi.enable = config.modules.desktop.hidpi;

  # Default low-level Linux system packages.
  environment = {
    systemPackages = with pkgs; [
      exfat
      hfsprogs
      ntfs3g
      openssl
      patchelf
      sshfs
      usbutils
      zlib
      zstd
    ];
  };

  # Location, timezone and internationalisation.
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  # Security.
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };

    # Prevent replacing the running kernel without reboot.
    protectKernelImage = true;
  };

  # Linux user and homedir settings.
  user = {
    extraGroups = [ "input" "disk" "audio" "video" "systemd-journal" ];
    initialHashedPassword = config.secrets.password;
  };

  users = {
    # Empty root password to begin with.
    extraUsers.root.initialHashedPassword = config.secrets.password;

    # Ensure only way to change users/groups is through this file.
    mutableUsers = false;
  };
}

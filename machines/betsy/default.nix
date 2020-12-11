# Betsy - personal ThinkPad E490 running NixOS.
{ config, pkgs, ... }: {
  imports = [
    ../../.

    # NOTE: Lenovo's T490 appears to be the closest to my E490.
    # REVIEW: Check https://github.com/NixOS/nixos-hardware for updates.
    <nixos-hardware/lenovo/thinkpad/t490>
    <nixos-hardware/common/pc/laptop>
    <nixos-hardware/common/pc/laptop/ssd>

    <modules/desktop>

    <modules/dev>
    <modules/dev/go.nix>
    <modules/dev/javascript.nix>
    <modules/dev/rust.nix>
    <modules/dev/python.nix>

    <modules/editors/emacs.nix>
    <modules/editors/vim.nix>

    <modules/media>

    <modules/ops>
    <modules/ops/docker.nix>
    <modules/ops/kafka.nix>
    <modules/ops/kubernetes.nix>

    <modules/term>
    <modules/term/direnv.nix>
    <modules/term/git.nix>
    <modules/term/gnupg.nix>
    <modules/term/ssh.nix>
    <modules/term/zsh.nix>

    <modules/web/chrome.nix>
    <modules/web/dropbox.nix>
    <modules/web/firefox.nix>
    <modules/web/slack.nix>
    <modules/web/zoom.nix>
  ];

  hardware = {
    bluetooth.enable = true;

    # NOTE: https://nixos.wiki/wiki/Accelerated_Video_Playback
    opengl = {
      enable = true;

      driSupport = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [
        beignet
        intel-media-driver
        libvdpau-va-gl
        vaapiIntel
        vaapiVdpau
        blueman
      ];
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    nur = import (builtins.fetchTarball {
      url =
        "https://github.com/nix-community/NUR/archive/d681086fc8f47ad3319aa8315aa8deb6c8f04fa7.tar.gz";
      sha256 = "049c90wc1l6bsn0dcg763434ny6r4bb81af6nr3gvrrzsa5jzn7j";
    }) { inherit pkgs; };
  };

  boot = {
    # Betsy's LUKS crypted root.
    initrd.luks.devices = {
      root = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;
      };
    };

    # Kernel tuning.
    kernel.sysctl = {
      # NOTE: An inotify watch consumes 1kB on 64-bit machines.
      "fs.inotify.max_user_watches" = 1048576; # default:  8192
      "fs.inotify.max_user_instances" = 1024; # default:   128
      "fs.inotify.max_queued_events" = 32768; # default: 16384
      "sysrq" = 1; # alt+prtsc
    };
  };

  # Hopefully prolong the life of this ThinkPad's SSD.
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # Hardware specific packages.
  environment.systemPackages = with pkgs; [
    acpi
    libinput
    libinput-gestures
    linuxPackages.acpi_call
    linuxPackages.cpupower
    linuxPackages.tp_smapi
    lm_sensors
    microcodeIntel
    pciutils
    powertop
  ];

  # Backlight control.
  programs.light.enable = true;

  # Networking.
  #
  # NOTE: The global useDHCP flag is deprecated, therefore explicitly set to
  # false here. Per-interface useDHCP will be mandatory in the future.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.interfaces.wlp5s0.useDHCP = true;
  networking.hostName = "betsy";
  networking.wireless.enable = true;
  # networking.extraHosts = ''
  #   127.0.0.1 something
  # '';

  # Fan controller for IBM/Lenovo ThinkPads.
  # NOTE: https://gist.github.com/Yatoom/1c80b8afe7fa47a938d3b667ce234559
  services.thinkfan = {
    enable = true;
    sensors = ''
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp3_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp4_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp5_input
      hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp2_input
    '';
    levels = ''
      (0, 0, 65)
      (1, 50, 70)
      (2, 68, 74)
      (3, 72, 75)
      (4, 74, 78)
      (5, 76, 80)
      (7, 78, 32767)
    '';
  };

  # Power management.
  powerManagement.powertop.enable = true;
  services.acpid.enable = true;

  # Only GC when on AC power.
  systemd.services.nix-gc.unitConfig.ConditionACPower = true;

  # Fix Intel CPU throttling affecting ThinkPads.
  services.throttled.enable = true;

  # Blue light filtering.
  # TODO: Not on VMWare VM.
  services.redshift = {
    enable = true;
    temperature = {
      day = 6500;
      night = 2300;
    };
  };

  # Work.
  nixpkgs.overlays = [
    (import (builtins.fetchGit {
      url = config.my.secrets.work_overlay_url;
      ref = "master";
      rev = "14ddc3382c268aca9547d173f00562cedb485f7b";
    }))
  ];
  my.packages = with pkgs; [ ];
}

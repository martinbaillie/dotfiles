{ pkgs, inputs, ... }: {
  # NOTE: Lenovo's T490 appears to be the closest to my E490.
  # REVIEW: Check https://github.com/NixOS/nixos-hardware for updates.
  imports = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t490 ];

  modules = {
    desktop = {
      enable = true;

      # Ditching Wayland again.
      # wm = "sway";
      wm = "exwm";

      dpi = 119;
    };

    editors = {
      emacs = {
        enable = true;
        package = pkgs.emacsGitNativeComp;
      };

      vim.enable = true;

      default = "emacs";
    };

    dev = {
      enable = true;
      python.enable = true;
      go.enable = true;
    };

    services = {
      ssh.enable = true;
      #docker.enable = true;
    };

    shell = {
      enable = true;

      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      ssh.enable = true;
      zsh.enable = true;
    };

    web = {
      browser = {
        firefox = {
          enable = true;
          tridactyl = true;
        };
        #  chromium.enable = true;
        #  #nyxt.enable = true;
      };
      #zoom.enable = true;
    };
  };

  user.packages = with pkgs; [ transmission-remote-gtk ];

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
  };

  boot = {
    loader = {
      # Allow the NixOS installation to modify EFI boot variables.
      efi.canTouchEfiVariables = true;

      # Choose the default generation faster.
      timeout = 1;

      # Simplistic EFI boot loader.
      # Or, how I learned to give up and accept systemd.
      systemd-boot = {
        enable = true;

        # Only show the last 10 generations that haven't been GCd.
        configurationLimit = 10;

        # Fix a security hole in place for the sake of backwards compatibility.
        editor = false;
      };
    };

    # Pretty boot loading screens.
    plymouth.enable = true;

    # Betsy's LUKS crypted root.
    initrd.luks.devices = {
      root = {
        device = "/dev/nvme0n1p2";
        preLVM = true;
        allowDiscards = true;
      };
    };

    # kernelParams = [ "psmouse.synaptics_intertouch=1" ];
    kernelModules = [ "kvm-intel" ];

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
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
  };
  user.extraGroups = [ "networkmanager" ];

  # TODO: Do I really need this still?
  # Fan controller for IBM/Lenovo ThinkPads.
  # NOTE: https://gist.github.com/Yatoom/1c80b8afe7fa47a938d3b667ce234559
  # services.thinkfan = {
  #   enable = true;
  #   sensors = ''
  #     hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp3_input
  #     hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp4_input
  #     hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input
  #     hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp5_input
  #     hwmon /sys/devices/platform/coretemp.0/hwmon/hwmon5/temp2_input
  #   '';
  #   levels = ''
  #     (0, 0, 65)
  #     (1, 50, 70)
  #     (2, 68, 74)
  #     (3, 72, 75)
  #     (4, 74, 78)
  #     (5, 76, 80)
  #     (7, 78, 32767)
  #   '';
  # };

  # DBus.
  programs.dconf.enable = true;
  services = {
    dbus.packages = with pkgs; [ dconf ];

    # DBus service that allows applications to update firmware.
    fwupd.enable = true;
  };

  home.services = {
    # Compositor.
    picom = {
      backend = "glx";
      vSync = true;
    };
    polybar.config = {
      "bar/top" = {
        height = 22;
        offset-y = 3;
      };
    };
  };

  # Keyboard.
  services.xserver = {
    xkbOptions = "altwin:swap_alt_win,terminate:ctrl_alt_bksp";
    #videoDrivers = [ "nvidia" ];
  };
  services.interception-tools = {
    enable = true;

    # Keyboard modifications:
    # 1. Use CAPS as CTRL when held; ESC when pressed alone.
    udevmonConfig = with pkgs; ''
      - JOB: "${interception-tools}/bin/intercept -g $DEVNODE | ${interception-tools-plugins.caps2esc}/bin/caps2esc | ${interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
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
  location.provider = "geoclue2";
  services.redshift = {
    enable = true;
    temperature = {
      day = 6500;
      night = 2300;
    };
  };
}

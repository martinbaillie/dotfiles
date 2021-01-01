{ config, lib, pkgs, options, ... }: {
  imports = let
    inherit (lib) optional;
    inherit (builtins) pathExists;

    # Generated NixOS hardware configuration.
    hardware = /etc/nixos/hardware-configuration.nix;
  in [
    # NixOS version of home-manager.
    <home-manager/nixos>
  ] ++ (optional (pathExists hardware) hardware);

  # NixOS version.
  system.stateVersion = "20.09";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  nix = {
    # Automatically detects files in the store that have identical contents.
    autoOptimiseStore = true;

    gc = {
      # Automatically run the Nix garbage collector daily.
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };

    # Users that have additional rights when connecting to the Nix daemon.
    trustedUsers = [ "root" "@wheel" config.my.username ];
  };

  # Boot and console.
  boot = {
    loader = {
      # Allow the NixOS installation to modify EFI boot variables.
      efi.canTouchEfiVariables = true;

      # Choose the default generation faster.
      timeout = 1;

      # Simplistic boot loader.
      # Or, how I learned to give up and accept systemd.
      systemd-boot = {
        enable = true;

        # Only show the last 10 generations that haven't been GCd.
        configurationLimit = 10;

        # Fix a security hole in place for the sake of backwards compatibility.
        editor = false;
      };
    };

    # Loading screens.
    plymouth.enable = true;

    # Cattle not pets.
    cleanTmpDir = true;
  };

  # Fix early boot display.
  hardware.video.hidpi.enable = config.my.hidpi;

  console = {
    keyMap = "us";
    # font = "Lat2-Terminus16";
  };

  # Default low-level system packages.
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
    ];
  };

  # Location, timezone and internationalisation.
  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_AU.UTF-8";

  # Firewall.
  networking.firewall.enable = true;
  networking.firewall.allowPing = true;

  # Security.
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;

  # Remote access.
  services.openssh = {
    enable = true;
    forwardX11 = true;
    permitRootLogin = "no";
    passwordAuthentication = true;
  };
  # services.tailscale.enable = true;

  # DBus.
  programs.dconf.enable = true;
  services.dbus.packages = with pkgs; [ gnome3.dconf ];

  services.fwupd.enable = true;

  # Automounting and virtual filesystem.
  #services.gvfs.enable = true;

  my = {
    # Homedir.
    home.xdg = {
      mime.enable = true;
      mimeApps.enable = true;
    };

    # User.
    user = {
      description = config.my.fullname;
      isNormalUser = true;
      uid = 1000;
      extraGroups =
        [ "wheel" "input" "disk" "audio" "video" "systemd-journal" ];
      initialHashedPassword = config.my.secrets.password;
    };
  };

  users = {
    # Empty root password to begin with.
    extraUsers.root.initialHashedPassword = "";

    # Zshell everywhere.
    defaultUserShell = pkgs.zsh;

    # Ensure only way to change users/groups is through this file.
    mutableUsers = false;
  };
}

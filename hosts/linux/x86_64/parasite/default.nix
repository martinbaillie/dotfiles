# VMWare-based NixOS VM.
{ config, lib, pkgs, ... }:

{
  modules = {
    services = {
      ssh.enable = true;
    };

    web = {
      browser = {
        firefox = {
          enable = true;
          tridactyl = true;
        };
      };
    };

    desktop = {
      enable = true;
      wm = "exwm";
      hidpi = true;
      # dpi = 119;
    };

    editors = {
      emacs = {
        enable = true;
        # package = pkgs.emacsGitNativeComp;
      };
      vim.enable = true;

      default = "emacs";
    };

    shell = {
      enable = true;

      direnv.enable = true;
      git.enable = true;
      gnupg.enable = true;
      ssh.enable = true;
      zsh.enable = true;
    };
  };

  # Parasite only gets 3/4 of what its host has.
  nix.settings.cores = 12;

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
    # plymouth.enable = true;
  };

  # We'll let the host handle this.
  powerManagement.enable = false;

  # Replace ntpd by timesyncd for more accurate virtualisation alignment.
  services.timesyncd.enable = true;

  fileSystems."/etc/dotfiles" = {
    device = ".host:/dotfiles";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [ "nofail,allow_other,uid=${toString config.user.uid}" ];
  };

  # Match host user.
  user.uid = 501;

  # Automatically sign-in.
  services.getty.autologinUser = config.user.name;

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
}

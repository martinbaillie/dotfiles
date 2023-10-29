# MacBook Pro (16-inch, Apple Silicon, 2021) 64GB M1 Max.
{ pkgs, inputs, ... }: {
  # $ sysctl -n hw.ncpu
  nix.settings.cores = 10;

  modules = {
    desktop = {
      enable = true;
      sudoTouchID = true;
      hammerspoon.enable = true;
    };

    editors = {
      default = "emacs";
      emacs = {
        enable = true;
        # package = pkgs.emacsUnstable.overrideAttrs (_: {
        #   src = inputs.emacs-macos;
        # });
      };
      vim.enable = true;
    };

    dev = {
      enable = true;
      go.enable = true;
      javascript = {
        enable = true;
        typescript.enable = true;
      };
      jvm = {
        enable = true;
        bazel.enable = false;
      };
      python.enable = true;
    };

    ops = {
      enable = true;
      aws.enable = true;
      kubernetes.enable = true;
    };

    services = {
      dropbox.enable = true;
      docker.enable = true;
      ssh.enable = true;
    };

    shell = {
      enable = true;
      direnv.enable = true;
      git = {
        enable = true;
        monorepo = true;
      };
      gnupg = {
        enable = true;
        cacheTTL = 34560000;
      };
      ssh.enable = true;
      zsh.enable = true;
    };

    web = {
      browser = {
        firefox = {
          enable = true;
          tridactyl = true;
        };
      };
    };
  };

  homebrew.casks = [ "discord" "gimp" "drawio" "monodraw" "vlc" "amazon-chime" ];
}

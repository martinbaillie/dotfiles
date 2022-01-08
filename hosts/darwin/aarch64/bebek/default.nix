# MacBook Air (13-inch, M1, 2020) 8GB Apple M1.
{ pkgs, ... }: {
  nix = rec {
    # $ sysctl -n hw.ncpu
    buildCores = 8;
    maxJobs = buildCores;
  };

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
        package = pkgs.emacsGcc;
      };

      vim.enable = true;
    };

    dev = {
      enable = true;
      go.enable = true;
      jvm.bazel.enable = true;
      python.enable = true;
      frontend.enable = true;
      javascript = {
        enable = true;
        typescript.enable = true;
      };
    };

    services = {
      cachix.enable = true;
      dropbox.enable = true;
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
        chromium.enable = true;
      };
      zoom.enable = true;
    };
  };

  homebrew.casks = [ "transmission-remote-gui" "workflowy" "spotify" "vlc" ];
}

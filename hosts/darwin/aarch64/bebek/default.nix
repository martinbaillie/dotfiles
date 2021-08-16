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
    };

    editors = {
      default = "emacs";

      emacs = {
        enable = true;
        package = pkgs.emacsGcc;
      };

      vim.enable = true;
    };

    dev = { enable = true; };

    services.dropbox.enable = true;

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

  homebrew.casks = [ "transmission-remote-gui" ];
}

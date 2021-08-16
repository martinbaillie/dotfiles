{ pkgs, ... }: {
  modules = {
    desktop = {
      enable = true;
      wm = "exwm";
      # wm = "sway";
    };

    theme = { mode = "dark"; };

    editors = {
      emacs = {
        enable = true;
        package = pkgs.emacs;
      };

      vim.enable = true;

      default = "emacs";
    };

    services = {
      ssh.enable = true;
      docker.enable = true;
    };

    shell = {
      enable = true;

      direnv.enable = true;
      zsh.enable = true;
      git.enable = true;
      ssh.enable = true;
    };

    web = {
      browser = {
        firefox = {
          enable = true;
          tridactyl = true;
        };
        chromium.enable = true;
        nyxt.enable = true;
      };
      zoom.enable = true;
    };
  };
}

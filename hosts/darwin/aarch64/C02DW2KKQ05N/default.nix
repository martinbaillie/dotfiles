# MacBook Pro (13-inch, M1, 2020) 16GB Apple M1.
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

    services = {
      cachix.enable = true;
      docker.enable = true;
    };

    dev = {
      enable = true;
      go.enable = true;
      frontend.enable = true;
      javascript = {
        enable = true;
        typescript.enable = true;
      };
      python.enable = true;
      rust.enable = true;
    };

    ops = {
      enable = true;
      aws.enable = true;
      kubernetes.enable = true;
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
      };
      slack.enable = true;
      zoom.enable = true;
    };
  };

  homebrew.casks = [
    # "blackhole-16ch" # Zero latency audio mux (https://git.io/JVQ4B).
    "drawio" # Pretty boxes and lines.
    "licecap" # Screen recordings to GIF (supports arm64).
  ];
}

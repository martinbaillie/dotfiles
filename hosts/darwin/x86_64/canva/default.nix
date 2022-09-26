# MacBook Pro (16-inch, Intel, 2019) 64GB 8-core i9
{ pkgs, ... }: {
  nix.settings = rec {
    # $ sysctl -n hw.ncpu
    cores = 16;
    max-jobs = cores;
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
        package = pkgs.emacs;
        # pkgs.emacsGitNativeComp.overrideAttrs
        #   (_: {
        #     # Process background thread patch.
        #     src = pkgs.fetchgit {
        #       url = "https://github.com/tyler-dodge/emacs.git";
        #       rev = "b386047f311af495963ad6a25ddda128acc1d461";
        #       sha256 = "t7r+6C05Amx5XV75H9Y7xt1iCX6g4YVwhc1q+33Glsw=";
        #     };
        #   });
      };

      vim.enable = true;
    };

    dev = {
      enable = true;
      frontend.enable = true;
      go.enable = true;
      javascript = {
        enable = true;
        typescript.enable = true;
      };
      protobuf = {
        enable = true;
        grpc.enable = true;
      };
      jvm = {
        enable = true;
        bazel.enable = true;
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
    };
  };

  homebrew.casks = [ "vlc" "gimp" "nosql-workbench" "drawio" ];
}

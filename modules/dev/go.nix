{ config, pkgs, ... }: {
  my = {
    packages = with pkgs; [
      delve
      errcheck
      go2nix
      gocode
      godef
      gofumpt
      golangci-lint
      golint
      gomodifytags
      go-protobuf
      gotags
      gotests
      gotestsum
      gotools
      protobuf
      vgo2nix

      unstable.go
      unstable.gopls
    ];

    home.xdg.configFile = {
      "zsh/rc.d/env.go.zsh".source = <config/go/env.zsh>;
    };

    # Ensure Go modules work with $WORK private (ssh keyed) repositories.
    env.GOPRIVATE = config.my.secrets.work_vcs_host + "/"
      + config.my.secrets.work_vcs_path + "/*";
  };
}

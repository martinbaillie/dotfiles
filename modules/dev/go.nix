{ config, pkgs, ... }: {
  my = {
    packages = with pkgs; [
      errcheck
      go2nix
      gocode
      godef
      golangci-lint
      golint
      go-protobuf
      gotags
      gotests
      gotestsum
      gotools
      protobuf
      go
      unstable.gopls
      unstable.gomodifytags
    ];

    home.xdg.configFile = {
      "zsh/rc.d/env.go.zsh".source = <config/go/env.zsh>;
    };

    # Ensure Go modules work with $WORK private (ssh keyed) repositories.
    env.GOPRIVATE = config.my.secrets.work_vcs_host + "/"
      + config.my.secrets.work_vcs_path + "/*";
  };
}

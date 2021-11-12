{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.go;
in
{
  options.modules.dev.go = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      delve
      errcheck
      go
      go-protobuf
      go2nix
      gocode
      godef
      gofumpt
      golangci-lint
      golint
      gomodifytags
      gopls
      gore
      gotags
      gotests
      gotestsum
      gotools
      protobuf
      vgo2nix
    ];

    env = {
      # Ensure Go modules work with $WORK private (ssh keyed) repositories.
      GOPRIVATE = config.secrets.work_vcs_host + "/"
        + config.secrets.work_vcs_path + "/*";
      GOPATH = "$HOME/Code/go";
      GOOS = "$(uname -s | tr '[:upper:]' '[:lower:]')";
      PATH = [ "$GOPATH/bin" ];
    };
  };
}

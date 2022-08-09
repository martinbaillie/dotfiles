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
      go2nix
      gocode
      godef
      golint
      gomodifytags
      gore
      gotests
      gotestsum
      protobuf
      revive

      unstable.go_1_19
      unstable.gofumpt
      # unstable.gopls
      # unstable.golangci-lint
    ]
    ++ optional config.modules.dev.jvm.bazel.enable bazel-gazelle
    ++ optionals config.modules.dev.protobuf.grpc.enable [
      protoc-gen-go
      protoc-gen-go-grpc
    ];

    env = {
      # Ensure Go modules work with $WORK private (SSH keyed) repositories.
      GOPRIVATE = config.secrets.work_vcs_host + "/"
        + config.secrets.work_vcs_path + "/*";
      GOPATH = "$XDG_DATA_HOME/go";
      GOOS = "$(uname -s | tr '[:upper:]' '[:lower:]')";
      PATH = [ "$GOPATH/bin" ];
    };
  };
}

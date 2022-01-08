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
      golangci-lint
      golint
      gomodifytags
      gore
      gotags
      gotests
      gotestsum
      gotools
      protobuf
      vgo2nix

      # Golang we hardly knew ye...
      # Here I accept fate and play with 1.18's generics.
      # TODO: Move back to upstream once merged.
      (go_1_17.overrideAttrs
        (oldattrs: rec {
          version = "1.18beta1";
          src = fetchurl {
            url = "https://dl.google.com/go/go${version}.src.tar.gz";
            sha256 = "sha256-QYwCjbFGmctbLUkHrTpBnXn3ibMZFu+HZIZ+SnjmU6E=";
          };
          patches = [ ];
        }))

      unstable.gofumpt
      unstable.gopls
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
      GOPATH = "$HOME/Code/go";
      GOOS = "$(uname -s | tr '[:upper:]' '[:lower:]')";
      PATH = [ "$GOPATH/bin" ];
    };
  };
}

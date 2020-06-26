{ pkgs, ... }: {
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
  };
}

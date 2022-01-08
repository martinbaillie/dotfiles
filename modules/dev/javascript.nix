{ config, lib, pkgs, ... }:
with lib;
let cfg = config.modules.dev.javascript;
in
{
  options.modules.dev.javascript = {
    enable = my.mkBoolOpt false;
    typescript.enable = my.mkBoolOpt false;
  };

  config = mkIf cfg.enable {
    user.packages = with pkgs;
      [
        nodejs

        nodePackages.node2nix
        nodePackages.prettier
        nodePackages.stylelint
        nodePackages.js-beautify

        # FIXME: Various things still call this `json-ls` so alias required.
        nodePackages.vscode-json-languageserver-bin
        (runCommand "json-ls-alias" { } ''
          mkdir -p $out/bin
          ln -s \
            ${nodePackages.vscode-json-languageserver-bin}/bin/json-languageserver \
            $out/bin/json-ls
        '')
      ] ++ (optionals cfg.typescript.enable [
        nodePackages.typescript
        nodePackages.typescript-language-server
      ]) ++ optional config.modules.dev.protobuf.grpc.enable protoc-gen-grpc-web;
  };
}

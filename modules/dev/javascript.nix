{ pkgs, ... }: {
  my.packages = with pkgs; [
    nodejs
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.node2nix
    nodePackages.prettier
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin

    # Various things call this `json-ls`.
    nodePackages.vscode-json-languageserver-bin
    (runCommand "json-ls-alias" { } ''
      mkdir -p $out/bin
      ln -s \
        ${nodePackages.vscode-json-languageserver-bin}/bin/json-languageserver \
        $out/bin/json-ls
    '')
  ];
}

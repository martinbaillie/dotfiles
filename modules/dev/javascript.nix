{ pkgs, ... }: {
  my.packages = with pkgs; [
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    nodePackages.javascript-typescript-langserver
    nodePackages.prettier
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-css-languageserver-bin
    nodePackages.vscode-html-languageserver-bin
    nodejs
  ];
}

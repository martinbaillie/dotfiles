{ pkgs, ... }: {
  my.packages = with pkgs; [
    nodejs
    nodePackages.javascript-typescript-langserver
    nodePackages.prettier
  ];
}

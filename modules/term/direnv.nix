{ pkgs, ... }: {
  my.packages = with pkgs; [ direnv (import <nixpkgs-unstable> { }).lorri ];
}

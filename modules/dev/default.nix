{ pkgs, ... }: { my.packages = with pkgs; [ gnumake cmake shellcheck nixfmt ]; }

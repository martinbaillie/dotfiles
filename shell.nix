{ pkgs }:

with pkgs;
let
  nixBin = writeShellScriptBin "nix" ''
    ${nixFlakes}/bin/nix --option experimental-features "nix-command flakes" "$@"
  '';
in
mkShell {
  buildInputs = [ git nix-zsh-completions gnumake screen ];
  shellHook = ''
    export FLAKE="$(pwd)"
    export PATH="${nixBin}/bin:$PATH"
  '';
}

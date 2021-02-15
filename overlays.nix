[
  (self: super:
    with super; {
      # My own "packages"—mostly macOS Applications.
      my = import ./packages { inherit (super) lib pkgs; };

      # Provide an unstable overlay of nixpkgs.
      unstable = import <nixpkgs-unstable> { inherit config; };

      # TODO: Fix upstream.
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/emacs-modes/melpa-packages.nix#L151
      emacs-pdf-tools =
        callPackage ./packages/emacs/pdf-tools { stdenv = clangStdenv; };

      emacsWithPackages =
        (pkgs.emacsPackagesNgGen pkgs.emacsGcc).emacsWithPackages;
    })

  # Emacs overlay.
  (import (builtins.fetchTarball # <2021-12-02 Mon>
    "https://github.com/nix-community/emacs-overlay/archive/e86b0f6d38f29e3b27032977db4f431e2f9d1a9b.tar.gz"))

  # Mozilla overlay (for Rust, Firefox).
  (import (builtins.fetchTarball # 17/07/20
    "https://github.com/mozilla/nixpkgs-mozilla/archive/efda5b357451dbb0431f983cca679ae3cd9b9829.tar.gz"))
]

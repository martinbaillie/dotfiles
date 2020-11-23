[
  (self: super:
    with super; {
      # My own "packages" - mostly desktop apps.
      my = import ./packages { inherit (super) lib pkgs; };

      # Provide a stable overlay.
      stable = import <nixpkgs-stable> { inherit config; };

      # TODO: Fix upstream
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/emacs-modes/melpa-packages.nix#L151
      emacs-pdf-tools =
        callPackage ./packages/emacs/pdf-tools { stdenv = clangStdenv; };

      # Fix Go clang path on Darwin.
      # REVIEW: https://github.com/NixOS/nixpkgs/pull/91347
      go = super.go.overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs ++ [ self.makeWrapper ];
        postInstall = with self.darwin.apple_sdk.frameworks;
          with self.stdenv;
          lib.optionalString isDarwin ''
            wrapProgram $out/share/go/bin/go \
              --suffix CGO_CFLAGS  ' ' '-iframework ${CoreFoundation}/Library/Frameworks -iframework ${Security}/Library/Frameworks' \
              --suffix CGO_LDFLAGS ' ' '-F${CoreFoundation}/Library/Frameworks -F${Security}/Library/Frameworks'
          '';
      });
    })

  # Wayland overlay.
  # (import (builtins.fetchTarball {
  #   url =
  #     "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz";
  # }))

  # Emacs overlay.
  (import (builtins.fetchTarball # <2020-11-02 Mon>
    "https://github.com/nix-community/emacs-overlay/archive/c57bba0fcc6386dc95ff92f0b7b192135725bd07.tar.gz"))

  # Emacs overlay (Linux native-comp + pgtk builds).
  (import (builtins.fetchTarball # <2020-11-03 Tue>
    "https://github.com/mjlbach/emacs-pgtk-nativecomp-overlay/archive/5286d508eaf53c82ec45f7bcf1cf63557668bb38.tar.gz"))

  # Mozilla overlay for Rust.
  (import (builtins.fetchTarball # 17/07/20
    "https://github.com/mozilla/nixpkgs-mozilla/archive/efda5b357451dbb0431f983cca679ae3cd9b9829.tar.gz"))
]

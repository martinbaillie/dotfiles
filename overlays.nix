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

      # Patch a hysterisis issue in libinput on my ThinkPad.
      # NOTE: https://gitlab.freedesktop.org/libinput/libinput/-/issues/286
      libinput = super.libinput.overrideAttrs
        (o: { patches = o.patches ++ [ ./packages/libinput/libinput.patch ]; });

      emacsWithPackages =
        (pkgs.emacsPackagesNgGen pkgs.emacsGcc).emacsWithPackages;
    })

  # Emacs overlay.
  (import (builtins.fetchTarball # <2020-12-21 Mon>
    "https://github.com/nix-community/emacs-overlay/archive/aa95116c0259a365a0d97715b74f3559112869ae.tar.gz"))

  # Mozilla overlay (for Rust, Firefox).
  (import (builtins.fetchTarball # 17/07/20
    "https://github.com/mozilla/nixpkgs-mozilla/archive/efda5b357451dbb0431f983cca679ae3cd9b9829.tar.gz"))
]

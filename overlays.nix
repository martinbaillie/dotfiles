[
  (self: super:
    with super; {
      # Allow unstable.
      unstable = import <nixpkgs-unstable> { inherit config; };

      # My own packages.
      my = import ./packages { inherit (super) lib pkgs; };

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

  # Build Emacs from bleeding-edge source.
  (import (builtins.fetchTarball
    # But pin to a particular commit so I can opt-in for upgrades.
    "https://github.com/nix-community/emacs-overlay/archive/05258fa4fedf87c1f7eee7686838f8bee3ee5cf6.tar.gz"))

  # Mozilla overlay for Rust.
  (import (builtins.fetchTarball
    "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz"))
]

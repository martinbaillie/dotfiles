[
  (self: super:
    with super; {
      # Allow unstable.
      unstable = import <nixpkgs-unstable> { inherit config; };

      # My own packages.
      my = import ./packages { inherit (super) lib pkgs; };
    })

  # Wayland overlay.
  # (import (builtins.fetchTarball {
  #   url =
  #     "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz";
  # }))

  # Build Emacs from bleeding-edge source.
  (import (builtins.fetchTarball {
    # But pin to a particular commit so I can opt-in for upgrades.
    url =
      "https://github.com/nix-community/emacs-overlay/archive/05258fa4fedf87c1f7eee7686838f8bee3ee5cf6.tar.gz";
  }))
]

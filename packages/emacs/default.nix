{ pkgs, ... }:
with pkgs;
let
  inherit (stdenv) isLinux isDarwin;
  inherit (lib) strings optional optionals;
  emacs-pdf-tools = callPackage ./pdf-tools { stdenv = clangStdenv; };
  emacs = (emacsPackagesNgGen (emacsGit.overrideAttrs (old: rec {
    name = "emacs-git-${version}";
    # version = "20200329.0";
    version = "20200706.0";
    withCsrc = true;

    src = fetchFromGitHub {
      owner = "emacs-mirror";
      repo = "emacs";
      rev = "10a0941f4dcc85d95279ae67032ec04463a44d59";
      sha256 = "1gwczswxsv7jkqbgdsiyx3ad629gi9l28ywa7fga85fbia9gy998";
      # rev = "3273e2ace788a58bef77cef936021d151815ea94";
      # sha256 = "04scsvfq5id3992apwawh7w54zfivgn60bkl6j6ph7viwk6pw0vk";
    };

    patches = [
      # ./patches/tramp-detect-wrapped-gvfsd.patch
      ./patches/clean-env.patch
      ./patches/optional-org-gnus.patch
    ] ++ (optionals isDarwin [
      ./patches/fix-window-role.patch
      ./patches/no-frame-refocus.patch
      # I'm not using Yabai anymore.
      # ./patches/no-titlebar.patch
    ]);

    postPatch = ''
      ${old.postPatch}
      # Delete the built-in orgmode.
      rm -r test/lisp/org lisp/org etc/org etc/ORG-NEWS doc/misc/org.texi
    '';
  }))).emacsWithPackages
    (epkgs: (with epkgs.melpaPackages; [ vterm emacsql emacsql-sqlite ]));
in symlinkJoin {
  name = "emacs";
  paths = [
    emacs

    # Emacs external dependencies.
    discount
    editorconfig-core-c
    emacs-pdf-tools
    gcc
    languagetool
    pandoc
    zstd
    (optional isLinux wkhtmltopdf)
  ];
}

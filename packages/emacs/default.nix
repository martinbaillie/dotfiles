{ stdenv, lib, fetchurl, fetchFromGitHub, ncurses, pkgconfig, texinfo, libxml2
, gnutls, gettext, autoconf, automake, autoreconfHook, jansson, imagemagick
, librsvg, AppKit, GSS, ImageIO, git }:

# A more modern Emacs 27 with some macOS patches because Mituharu's MacPort
# doesn't have a 27 version yet and I really want that JSON parsing / LSP
# performance goodness.
#
# NOTE: This overlay was mostly pilfered from @cmacrae's dots.
stdenv.mkDerivation rec {
  name = "emacs-${version}";
  version = "27.0.90";

  src = fetchFromGitHub {
    owner = "emacs-mirror";
    repo = "emacs";

    # 27.0.90
    rev = "c5f255d68156926923232b1edadf50faac527861";
    sha256 = "13n82lxbhmkcmlzbh0nml8ydxyfvz8g7wsdq7nszlwmq914gb5nk";
  };

  enableParallelBuilding = true;

  patches = [ ./patches/clean-env.patch ./patches/fix-window-role.patch ];

  CFLAGS = "-DMAC_OS_X_VERSION_MAX_ALLOWED=101200";
  LDFLAGS = "-O3 -L${ncurses.out}/lib";

  nativeBuildInputs = [ pkgconfig autoconf automake autoreconfHook texinfo ];

  buildInputs = [
    ncurses
    libxml2
    gnutls
    gettext
    imagemagick
    librsvg
    AppKit
    GSS
    ImageIO
    jansson
    git
  ];

  hardeningDisable = [ "format" ];

  configureFlags = [
    "LDFLAGS=-L${ncurses.out}/lib"
    "--disable-ns-self-contained"
    "--disable-build-details"
    "--with-gnutls=yes"
    "--with-xml2=yes"
    "--with-modules"
    "--with-json"
  ];

  preConfigure = ''
    substituteInPlace lisp/international/mule-cmds.el \
      --replace /usr/share/locale ${gettext}/share/locale

    for makefile_in in $(find . -name Makefile.in -print); do
        substituteInPlace $makefile_in --replace /bin/pwd pwd
    done
  '';

  installTargets = [ "tags" "install" ];

  postInstall = ''
    mkdir -p $out/share/emacs/site-lisp
    cp ${./site-start.el} $out/share/emacs/site-lisp/site-start.el
    $out/bin/emacs --batch -f batch-byte-compile $out/share/emacs/site-lisp/site-start.el

    rm -rf $out/var
    rm -rf $out/share/emacs/${version}/site-lisp
    mkdir -p $out/Applications
    mv nextstep/Emacs.app $out/Applications
  '';

  meta = with stdenv.lib; {
    description = "Recent Emacs builds with some community patches.";
    homepage = "https://www.gnu.org/software/emacs/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ mbaillie ];
    platforms = platforms.darwin;

    longDescription = ''
      This is a recent build of GNU Emacs with some community patches.

      Included patches
      - fix-window-role: in lieu of the modifications from emacs-mac, this allows for better
                         window recognition/control
      - natural-title-bar: use macOS natural title bars
    '';
  };
}

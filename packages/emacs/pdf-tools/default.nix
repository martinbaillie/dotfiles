{ stdenv, lib, fetchFromGitHub, clang, gnumake, automake, autoconf, pkgconfig
, libpng, zlib, poppler }:

# The MELPA package version of this does not move the binary onto the Nix path.
# This is the only reason for this derivation.
#
# REVIEW: Is there a better way to do this with Nix?
stdenv.mkDerivation rec {
  pname = "emacs-pdf-tools-server";
  version = "0.90";
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "politza";
    repo = "pdf-tools";
    rev = "af1a5949c2dae59ffcbcf21cc4299fa2fc57ce72";
    sha256 = "0iv2g5kd14zk3r5dzdw7b7hk4b5w7qpbilcqkja46jgxbb6xnpl9";
  };
  buildInputs =
    [ clang gnumake automake autoconf pkgconfig libpng zlib poppler ];
  preConfigure = ''
    cd server
    ./autogen.sh
  '';
  installPhase = ''
    echo hello
    mkdir -p $out/bin
    cp -p epdfinfo $out/bin
  '';
  meta = with stdenv.lib; {
    homepage = "https://github.com/politza/pdf-tools";
    description = "Emacs support library for PDF files";
    maintainers = with maintainers; [ mbaillie ];
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}

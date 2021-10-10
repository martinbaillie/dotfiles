{ lib, stdenv, fetchurl, undmg }:

# Predictable Firefox for Darwin, controllable with home-manager.
stdenv.mkDerivation rec {
  pname = "Firefox";
  version = "93.0";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p "$out/Applications"
    cp -r Firefox.app "$out/Applications/Firefox.app"
  '';

  src = fetchurl {
    name = "Firefox-${version}.dmg";
    url =
      "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/sco/Firefox%20${version}.dmg";
    sha256 = "QjS5wD5/cX+VeEc1ZI6Cd5YYFdM5Kr3rPkggZ15ZRUM=";
  };

  meta = with lib; {
    description = "The Firefox web browser";
    homepage = "https://www.mozilla.org/en-GB/firefox";
    maintainers = with maintainers; [ mbaillie ];
    platforms = platforms.darwin;
  };
}

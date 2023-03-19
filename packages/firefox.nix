{ lib, stdenv, fetchurl, undmg, writeText }:

# Predictable Firefox for Darwin, controllable with home-manager.
stdenv.mkDerivation rec {
  pname = "Firefox";
  version = "111.0";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase =
    let
      policies = { DisableAppUpdate = true; };
      policiesJson = writeText "no-update-firefox-policy.json" (builtins.toJSON { inherit policies; });
    in
    ''
      mkdir -p "Firefox.app/Contents/Resources/distribution"
      ln -s ${policiesJson} "Firefox.app/Contents/Resources/distribution/policies.json"
      mkdir -p "$out/Applications"
      cp -r Firefox.app "$out/Applications/Firefox.app"
    '';

  src = fetchurl {
    name = "Firefox-${version}.dmg";
    url =
      "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/sco/Firefox%20${version}.dmg";
    sha256 = "oFCuXtbsaOrMugfBzOMxIeuu4geD+3jPilLf/5nJl6c=";
  };

  meta = with lib; {
    description = "The Firefox web browser";
    homepage = "https://www.mozilla.org/en-GB/firefox";
    maintainers = with maintainers; [ mbaillie ];
    platforms = platforms.darwin;
  };
}

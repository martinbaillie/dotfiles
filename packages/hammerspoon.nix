{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "Hammerspoon";
  version = "0.9.93";

  src = fetchzip {
    url =
      "https://github.com/Hammerspoon/hammerspoon/releases/download/0.9.93/Hammerspoon-0.9.93.zip";
    sha256 = "OMxINMxBoLV/jf8PV0PUjULuI9OGHRd6x9v7m1uwzmc=";
  };

  installPhase = ''
    mkdir -p $out/Applications/Hammerspoon.app
    mv ./* $out/Applications/Hammerspoon.app
    chmod +x "$out/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon"
  '';

  meta = with lib; {
    description = "Staggeringly powerful macOS desktop automation with Lua.";
    homepage = "https://www.hammerspoon.org";
    maintainers = with maintainers; [ mbaillie ];
    platforms = platforms.darwin;
  };
}

{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "Hammerspoon";
  version = "0.9.100";

  src = fetchzip {
    url =
      "https://github.com/Hammerspoon/hammerspoon/releases/download/0.9.100/Hammerspoon-0.9.100.zip";
    sha256 = "Q14NBizKz7LysEFUTjUHCUnVd6+qEYPSgWwrOGeT9Q0=";
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

{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "Hammerspoon";
  version = "0.9.90";

  src = fetchzip {
    url =
      "https://github.com/Hammerspoon/hammerspoon/releases/download/0.9.90/Hammerspoon-0.9.90.zip";
    sha256 = "1bv9ay07d65izfy73c9w9mj8pq8z45z0506vrssqrpswpl2dnyfb";
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

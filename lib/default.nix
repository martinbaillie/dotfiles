{ inputs, lib, pkgs, darwin, ... }:

let
  inherit (lib) makeExtensible attrValues foldr;
  inherit (modules) mapModules;

  modules = import ./modules.nix {
    inherit lib;
    inherit pkgs;
    self.attrs = import ./attrs.nix {
      inherit lib;
      self = { };
    };
  };

  mylib = makeExtensible (self:
    with self;
    mapModules ./.
      (file: import file { inherit self lib pkgs inputs darwin; }));
in
mylib.extend (self: super: foldr (a: b: a // b) { } (attrValues super))

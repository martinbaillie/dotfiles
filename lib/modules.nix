{ self, lib, ... }:

let
  inherit (builtins) attrValues readDir pathExists concatLists match;
  inherit (self.attrs) mapFilterAttrs;
  inherit (lib)
    id mapAttrsToList filterAttrs hasPrefix hasSuffix nameValuePair removeSuffix
    toLower systems;
  inherit (systems.elaborate { system = builtins.currentSystem; }) uname;
  os = toLower uname.system;
in
rec {
  mapModules = dir: fn:
    mapFilterAttrs (n: v: v != null && !(hasPrefix "_" n))
      (n: v:
        let path = "${toString dir}/${n}";
        in
        if v == "directory" && pathExists "${path}/default.nix" then
          nameValuePair n (fn path)
        else if v == "regular" && n != "default.nix"
          && match "[A-Za-z0-9_]+(\\.${os})?\\.nix$" n != null then
          nameValuePair (removeSuffix ".nix" n) (fn path)
        else
          nameValuePair "" null)
      (readDir dir);

  mapModules' = dir: fn: attrValues (mapModules dir fn);

  mapModulesRec = dir: fn:
    mapFilterAttrs (n: v: v != null && !(hasPrefix "_" n))
      (n: v:
        let path = "${toString dir}/${n}";
        in
        if v == "directory" then
          nameValuePair n (mapModulesRec path fn)
        else if v == "regular" && n != "default.nix"
          && match "[A-Za-z0-9_]+(\\.${os})?\\.nix$" n != null then
          nameValuePair (removeSuffix ".nix" n) (fn path)
        else
          nameValuePair "" null)
      (readDir dir);

  mapModulesRec' = dir: fn:
    let
      dirs = mapAttrsToList (k: _: "${dir}/${k}")
        (filterAttrs (n: v: v == "directory" && !(hasPrefix "_" n))
          (readDir dir));
      files = attrValues (mapModules dir id);
      paths = files ++ concatLists (map (d: mapModulesRec' d id) dirs);
    in
    map fn paths;
}

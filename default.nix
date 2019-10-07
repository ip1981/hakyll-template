{ pkgs ? import <nixpkgs> {}}:

let

  filtFn = root: path: type:
    let
      name = baseNameOf path;
      hidden = builtins.match "[._].+" name != null;
      nix = builtins.match ".*\\.nix" name != null;
      r =
        !hidden &&
        !nix    &&
        true;
    in builtins.trace (path + ": " + (if r then "yes" else "no")) r;

  fltsrc = builtins.filterSource (filtFn (builtins.toPath ./. + "/"));

  site = (import ./compiler { boot = pkgs; }).site;

  src = fltsrc ./src;

in pkgs.runCommand "site" { LANG = "C.UTF-8"; } ''
  ${site}/bin/site --source ${src} --output $out build
  ${site}/bin/site --source ${src} --output $out check
''

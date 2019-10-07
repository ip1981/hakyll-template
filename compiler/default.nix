{ boot ? import <nixpkgs> {} }:

let

  filtFn = root: path: type:
    let
      name = baseNameOf path;
      hidden = builtins.match "\\..+" name != null;
      nix = builtins.match ".*\\.nix" name != null;
      r = !hidden && !nix ;
    in builtins.trace (path + ": " + (if r then "yes" else "no")) r;

  fltsrc = builtins.filterSource (filtFn (builtins.toPath ./. + "/"));

  nixpkgs = boot.pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "897ec814c9c234f3ed9d60a1a713025d2f9fab2d";
    sha256 = "0alg5h5zmxdrnfdj94fa4yr5g7j7z3424k78aq44r0a0aqm20iy5";
  };

  config = {
    allowUnfree = true; # for local packages
    allowBroken = true; # some nixpkgs' nonsense
  };

  inherit (import nixpkgs { inherit config; }) pkgs;
  inherit (pkgs) lib;

  nixHaskellPackages =
    let
      isnix = n: _: null != builtins.match ".*\\.nix" n && n != "default.nix";
      files = lib.filterAttrs isnix (builtins.readDir ./.);
    in lib.mapAttrs' (n: _:
          { name = lib.removeSuffix ".nix" n;
            value = ./. + "/${n}";
          }) files;

  localHaskellPackages =
    let
      islocal = n: t: !lib.hasPrefix "." n && t == "directory";
      files = lib.filterAttrs islocal (builtins.readDir ./.);
    in lib.mapAttrs (n: _: fltsrc (./. + "/${n}")) files;

  haskellPackages =
    let

      hlib = pkgs.haskell.lib;

      set0 = pkgs.haskell.packages.ghc865;

      set1 = set0.extend (
        self: super:
          lib.mapAttrs (_: f: super.callPackage f {}) nixHaskellPackages
      );

      set2 = set1.extend (
        self: super:
          lib.mapAttrs (n: d: super.callCabal2nix n d {}) localHaskellPackages
      );

      set3 = set2.extend (
        self: super: {
          mkDerivation = drv: super.mkDerivation (drv // {
            buildTools = (drv.buildTools or []);

            # XXX a lot of troubles are cause by tests which require fancy packages of features.
            # XXX Enable tests for critical packages when unsure.
            doCheck = false;

            doHaddock = false;

            enableExecutableProfiling = false;
            enableLibraryProfiling = false;
          });

          primitive = self.primitive_0_7_0_0;
          primitive-extras = self.primitive-extras_0_8;

        });

      set = set3.extend (
        self: super:
          lib.mapAttrs (n: _:
              hlib.overrideCabal super.${n} (drv:
                {
                  doCheck = true;
                  configureFlags = (drv.configureFlags or []) ++ [
                    "--ghc-option=-Werror"
                  ];
                })
            ) localHaskellPackages);

    in set;

in haskellPackages

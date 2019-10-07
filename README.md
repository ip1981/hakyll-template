About
=====

This is a template site for [Hakyll](https://jaspervdj.be/hakyll/).
It is meant to be more flexible and powerful then the default template created by Hakyll.


Structure
=========

All inputs for Hakyll are under the [src](./src) directory. The
[compiler](./compiler) directory contains the [site builder](./compiler/site)
and may include any other Haskell dependencies.


Usage
=====

With Nix
--------

Use the [Nix](https://nixos.org/nix/) package manager:
```
$ nix build -f . -o www
```

This will build the site and put it into the `www` directory (a symbolic
link to a directory), ready to deploy.


Or:
```
$ nix build -f compiler site -o site
$ ./site/bin/site build
```

Manually
--------

1. Build the site builder: `cd compiler && cabal v2-build site`.
2. Use the site builder from the top directory:

```
$ /path/to/site --help
Static site compiler

Usage: site [-v|--verbose] [-o|--output DIR] [-s|--source DIR] [-c|--cache DIR]
            COMMAND

Available options:
  -v,--verbose             Run in verbose mode
  -o,--output DIR          Output directory (default: "_site")
  -s,--source DIR          Source directory (default: "./src")
  -c,--cache DIR           Cache directory (default: "_cache")
  -h,--help                Show this help text

Available commands:
  build                    Build the site
  clean                    Clean
  check                    Check links


$ /path/to/site build
Initialising...
  Creating store...
  Creating provider...
  Running rules...
Checking for out-of-date items
Compiling
  updated templates/default.html
  updated about.rst
  updated templates/post.html
  updated posts/2015-08-12-spqr.markdown
  updated posts/2015-10-07-rosa-rosa-rosam.markdown
  updated posts/2015-11-28-carpe-diem.markdown
  updated posts/2015-12-07-tu-quoque.markdown
  updated templates/archive.html
  updated templates/post-list.html
  updated archive.html
  updated contact.markdown
  updated css/default.css
  updated images/haskell-logo.png
  updated index.html
Success

```


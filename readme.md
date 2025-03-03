# nix-remote-build

Simple tool to build nix flake outputs on remote hosts. Can be useful if you want to build a locally modified flake output on a dedicated remote builder.

## Usage

```
Usage: nix-remote-build [-c] [-n] -o <Flake-Output> -b <Build-Host>

Options:
-o      Flake output to build
-b      Host to build on
-c      Copy back built derivation after building
-n      No signature check for copying back the built derivation
```

## Examples

Build flake output `.#foo` on host `bar.example.com`

```
$ nix-remote-build -o .#foo -b bar.example.com
```

Build flake output `nixpkgs#hello` on host `bar.example.com`

```
$ nix-remote-build -o nixpkgs#hello -b bar.example.com
```

Build NixOS configuration of host `foo` on host `bar.example.com` and copy the result to the local machine

```
$ nix-remote-build -o .#nixosConfigurations.foo.config.system.toplevel -b bar.example.com -c
```


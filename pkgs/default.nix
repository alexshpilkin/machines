{ nixpkgs ? import <nixpkgs>
, system ? builtins.currentSystem
, pkgs ? nixpkgs { inherit system; }
}:

pkgs.writeShellScriptBin "nope" ''
	echo "There could be a default package here, but there isn't." >&2; exit 1
''

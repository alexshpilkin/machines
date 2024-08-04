{ nixpkgs ? import <nixpkgs>
, system ? builtins.currentSystem
, pkgs ? nixpkgs { inherit system; }
, lib ? pkgs.lib
, stdenv ? pkgs.stdenv
, makeWrapper ? pkgs.makeWrapper
, openssl ? pkgs.openssl
}:

stdenv.mkDerivation rec {
	name = "acme-swanctl";
	src = ./.;
	nativeBuildInputs = [ makeWrapper ];
	buildInputs = [ openssl ];
	installPhase = ''
		runHook preInstall
		for file in *.sh; do
			install -Dm755 $file $out/bin/$file
			wrapProgram $out/bin/$file --prefix PATH : '${lib.makeBinPath buildInputs}'
		done
		runHook postInstall
	'';
}

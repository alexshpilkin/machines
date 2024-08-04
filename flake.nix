#!/usr/bin/env -S nixos-rebuild --flake

{
	inputs.flake-registry = {
		url = "github:NixOS/flake-registry";
		flake = false;
	};

	inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

	outputs = { self, flake-registry, nixpkgs }:
		let
			inherit (builtins) pathExists readDir;
			inherit (nixpkgs.lib)
				genAttrs filterAttrs hasSuffix mapAttrs mapAttrs' mkDefault mkIf
				nameValuePair nixosSystem removeSuffix systems;

			supportedSystems = systems.flakeExposed or systems.supported.hydra;

			nixPaths = dir:
				let
					isNix = entry: type:
						if type == "directory"
						then pathExists "${dir}/${entry}/default.nix"
						else hasSuffix ".nix" entry;
					toPair = entry: type:
						nameValuePair (removeSuffix ".nix" entry) "${dir}/${entry}";
				in mapAttrs' toPair (filterAttrs isNix (readDir dir));

			packagePaths = nixPaths ./pkgs;

			mkModule = name: path: { imports = [ path ]; };

			mkHost = name: path:
				let
					mkPackageArg = name: path:
						self.packages.${host.config.nixpkgs.system}.${name};
					host = nixosSystem {
						specialArgs =
							self.nixosModules // self.overlays //
							mapAttrs mkPackageArg packagePaths;
						modules = [
							{
								system.configurationRevision = mkIf (self ? rev) self.rev;
								networking.hostName = name;
								nix.registry.nixos-config.flake = self;
								nix.registry.nixpkgs.flake = nixpkgs;
								nix.settings.flake-registry =
									mkDefault "${flake-registry}/flake-registry.json";
							}
							path
						];
					};
				in host;

			mkOverlay = name: path: import path;

			mkPackage = system:
				let inherit (nixpkgs.legacyPackages.${system}) callPackage; in
				name: path: callPackage path {};

		in {
			nixosModules = mapAttrs mkModule (nixPaths ./modules);
			nixosConfigurations = mapAttrs mkHost (nixPaths ./hosts);
			overlays = mapAttrs mkOverlay (nixPaths ./overlays);
			packages = genAttrs supportedSystems (system:
				mapAttrs (mkPackage system) packagePaths);
			defaultPackage = mapAttrs (system: pkgs: pkgs.default) self.packages;
		};
}

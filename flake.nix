#!/usr/bin/env -S nixos-rebuild --flake

{
	inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

	outputs = { self, nixpkgs }:
		let
			inherit (builtins) pathExists readDir;
			inherit (nixpkgs.lib)
				filterAttrs hasSuffix mapAttrs mapAttrs' mkIf nameValuePair nixosSystem
				removeSuffix;

			nixPaths = dir:
				let
					isNix = entry: type:
						if type == "directory"
						then pathExists (dir + "/${entry}/default.nix")
						else hasSuffix ".nix" entry;
					toPair = entry: type:
						nameValuePair (removeSuffix ".nix" entry) (dir + "/${entry}");
				in mapAttrs' toPair (filterAttrs isNix (readDir dir));

			mkModule = name: path: { imports = [ path ]; };

			mkHost = name: path:
				nixosSystem {
					specialArgs = self.nixosModules // self.overlays;
					modules = [
						{
							system.configurationRevision = mkIf (self ? rev) self.rev;
							networking.hostName = name;
							nix.registry.nixos-config.flake = self;
							nix.registry.nixpkgs.flake = nixpkgs;
						}
						path
					];
				};

			mkOverlay = name: path: import path;

		in {
			nixosModules = mapAttrs mkModule (nixPaths ./modules);
			nixosConfigurations = mapAttrs mkHost (nixPaths ./hosts);
			overlays = mapAttrs mkOverlay (nixPaths ./overlays);
		};
}
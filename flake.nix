{
	inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

	outputs = { self, nixpkgs }:
		with nixpkgs.lib; {
			nixosModules = {
				by-uuid.imports = [ ./by-uuid.nix ];
			};

			# FIXME builtins.readDir etc?
			nixosConfigurations.etranger = nixosSystem {
				modules = [ hosts/etranger.nix ];
				specialArgs = self.nixosModules;
			};
		};
}

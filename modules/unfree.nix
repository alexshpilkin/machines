{ config, lib, ... }:

let
	inherit (lib) elem getName mkOption;
	inherit (lib.types) listOf str;

in {
	options = {
		nixpkgs.allowUnfreePackages = mkOption {
			type = listOf str;
			default = [ ];
			example = [ "broadcom-sta" "facetimehd-firmware" ];
		};
	};

	config = {
		nixpkgs.config.allowUnfreePredicate = pkg:
			elem (getName pkg) config.nixpkgs.allowUnfreePackages;
	};
}

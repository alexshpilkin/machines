{ config, lib, ... }:

let
	inherit (lib) mkIf mkMerge mkOption types;
	inherit (types) attrsOf listOf nullOr str submodule;

	uuidOpts = { name, config, ... }: {
		options.partuuid = mkOption {
			default = null;
			example = "7d444840-9dc0-11d1-b245-5ffdce74fad2";
			type = nullOr str;
			description = "Partition UUID of the device";
		};

		options.uuid = mkOption {
			default = null;
			example = "7d444840-9dc0-11d1-b245-5ffdce74fad2";
			type = nullOr str;
			description = "Filesystem UUID of the device";
		};

		config.device = mkMerge [
			(mkIf (config.partuuid != null) "/dev/disk/by-partuuid/${config.partuuid}")
			(mkIf (config.uuid != null) "/dev/disk/by-uuid/${config.uuid}")
		];
	};

in {
	options = {
		boot.initrd.luks.devices = mkOption {
			type = attrsOf (submodule uuidOpts);
		};
		fileSystems = mkOption {
			type = attrsOf (submodule uuidOpts);
		};
		swapDevices = mkOption {
			type = listOf (submodule uuidOpts);
		};
	};
}

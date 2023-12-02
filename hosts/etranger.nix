{ by-uuid, desktop, lib, macbook, unfree, ... }:

let
	inherit (builtins) elem;
	inherit (lib) getName;

in {
	system.stateVersion = "21.11";
	imports = [ by-uuid desktop macbook unfree ];

	hardware.enableRedistributableFirmware = true;
	nixpkgs.allowUnfreePackages = [
		"broadcom-sta"
		"facetimehd-calibration"
		"facetimehd-firmware"
	];

	# Boot loader

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# Filesystems

	boot.initrd.luks.devices.data = {
		uuid = "29a34665-337f-48fd-b775-74f3b294a578";
		preLVM = true;
		allowDiscards = true; # FIXME default for an SSD system?
	};

	fileSystems."/boot" = {
		partuuid = "1070982e-94b1-44fa-8030-20e4a825b05e";
		fsType = "vfat";
	};

	fileSystems."/" = {
		uuid = "0ff18cb0-87e8-4119-817f-207d0bcfefe1";
		fsType = "xfs";
	};

	fileSystems."/home" = {
		uuid = "c6bedfe5-8686-4e5c-b38b-8245345be1bc";
		fsType = "xfs";
	};

	swapDevices = [ { uuid = "cfebf689-6703-4d61-b574-89a5714d8ebf"; } ];

	# Users

	users.users.alex = {
		uid = 1000;
		description = "Alex Shpilkin";
		isNormalUser = true;
		extraGroups = [ "adbusers" "wheel" ];
	};

	users.users.ser = {
		uid = 1001;
		description = "Sergey Shpilkin";
		isNormalUser = true;
	};
}

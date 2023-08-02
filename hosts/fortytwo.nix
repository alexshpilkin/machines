{ by-uuid, desktop, intel, lib, ... }:

{
	system.stateVersion = "21.11";
	imports = [ by-uuid desktop intel ];

	hardware.enableRedistributableFirmware = true;

	# Boot loader

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# Filesystems

	boot.initrd.luks.devices.data = {
		uuid = "b3173f22-70b6-43a6-89e3-6b341bfbe09e";
		preLVM = true;
		allowDiscards = true; # FIXME default for an SSD system?
	};

	fileSystems."/boot" = {
		partuuid = "82d74626-36b5-48b8-a9f6-a766bca290b2";
		fsType = "vfat";
	};

	fileSystems."/" = {
		uuid = "6af00c79-227a-4b39-a672-c64a2f5806ba";
		fsType = "xfs";
	};

	fileSystems."/home" = {
		uuid = "bb3f2ab6-a235-48ea-bb18-a4197e540709";
		fsType = "xfs";
	};

	swapDevices = [ { uuid = "d482b5ec-8534-47e3-8feb-155929ae3abf"; } ];

	# Users

	users.users.alex = {
		uid = 1000;
		description = "Alex Shpilkin";
		isNormalUser = true;
		extraGroups = [ "wheel" ];
	};

	users.users.ser = {
		uid = 1001;
		description = "Sergey Shpilkin";
		isNormalUser = true;
	};
}

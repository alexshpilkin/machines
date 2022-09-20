{ by-uuid, generic, intel, ... }:

{
	system.stateVersion = "21.11";
	imports = [ by-uuid generic intel ];

	hardware.enableRedistributableFirmware = true;

	# Boot loader

	boot.loader.grub = {
		enable = true;
		version = 2;
		# FIXME put this into by-uuid
		device = "/dev/disk/by-id/wwn-0x5000c5001f81ba8a";
	};

	# Filesystems

	boot.initrd.luks.devices.data = {
		uuid = "0e8a73d1-4505-4bb8-9953-83fcfaab844c";
		preLVM = true;
	};

	fileSystems."/boot" = {
		uuid = "c17c8b80-00e3-4b7e-b101-f9856ec00b7f";
		fsType = "ext4";
	};

	fileSystems."/" = {
		uuid = "3714e9b2-f2cd-414d-a1ba-2ab655368d1e";
		fsType = "xfs";
	};

	fileSystems."/home" = {
		uuid = "b2f86188-7cf9-405a-8f86-6f66fcde0058";
		fsType = "xfs";
	};

	swapDevices = [ { uuid = "88fdcf25-4ca4-415b-a1be-7591eeac6b5f"; } ];

	# Network

	networking.interfaces.enp0s25.useDHCP = true;

	# Users

	users.users.alex = {
		uid = 1000;
		description = "Alex Shpilkin";
		isNormalUser = true;
		extraGroups = [ "wheel" ];
	};
}

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

	networking.interfaces.enp0s25 = {
		useDHCP = true;
		wakeOnLan.enable = true;
	};

	boot.initrd.availableKernelModules = [ "e1000e" ];
	boot.initrd.network.enable = true;
	boot.initrd.network.ssh = {
		enable = true;
		hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
		authorizedKeys = [
			"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3Pvaf9+XvzdvLRA5CleeC6ph1hI/o3MVwvvI3xQoe7aRNWEPK5WD2J7MzIQnJBZxO7fWwkKBlEzv1NHLEHGUlM/6CwkjzZOh7b4hKSyfe7u9PSamY9dcuPblnEB7jyT10ezZT+6lqlue2dAmsHai+1jF6hoAqlY8jT4vhT2co3cZNtwOnjbrK8GA6rQiVkStIy3xma1goNV/Xl/zeC4M6qG7XXuJbWPY75v35O5QEtd/hwYFMBr6ShA/9OJ45V9qSk+njGkx0h6C0GNF10Y6Gq4J0ApDLVePx0kGWfvRECVhMFtFwRNeiPRKWWOEH7fp/teRYKB03HQFBusAsCdmF openpgp:0x4B3A894B"
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKGNzen6TbP0eCldtfPoREFvYfUivPSsIdR0ssr6+6uV alex@fortytwo.lointa.in"
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/zu4B9UxPz3Di+QIjxNV0Hh3oOOh0Vt2ajNfGIrZ9W alex@xiaoxin.lointa.in"
		];
	};

	services.tor.enable = true;
	services.tor.relay.onionServices = {
		ssh = { version = 3; map = [ 22 ]; };
	};

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
		extraGroups = [ "wheel" ];
	};
}

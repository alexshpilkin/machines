{ amd, by-uuid, desktop, lib, pkgs, power-profiles-daemon, ... }:

{
	system.stateVersion = "21.11";
	imports = [ amd by-uuid desktop ];

	boot.extraModprobeConfig = ''
		options cfg80211 ieee80211_regdom="IL"
	'';
	#boot.initrd.kernelModules = [ "amdgpu" ];
	boot.kernelPackages = pkgs.linuxPackages_testing;

	hardware.enableRedistributableFirmware = true;
	hardware.wirelessRegulatoryDatabase = true;

	services.fwupd.enable = true;
	services.power-profiles-daemon.package = pkgs.power-profiles-daemon.overrideAttrs {
		src = power-profiles-daemon;
		version = power-profiles-daemon.rev;
	};

	# Boot loader

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	# Filesystems

	boot.initrd.luks.devices.data = {
		uuid = "cfc61203-297d-4f50-9b1c-89018a20ca17";
		preLVM = true;
		allowDiscards = true;
	};

	fileSystems."/boot" = {
		partuuid = "8a4c7833-8d59-43e0-ac97-98958bb656b8";
		fsType = "vfat";
		options = [ "umask=0077" ];
	};

	fileSystems."/" = {
		uuid = "da70a97b-7ef1-4e28-aa0d-c64bce0725e2";
		fsType = "xfs";
		options = [ "discard" ];
	};

	fileSystems."/home" = {
		uuid = "b537c014-a521-4761-837a-9e5e17988c24";
		fsType = "xfs";
		options = [ "discard" ];
	};

	swapDevices = [ { uuid = "f5378744-47fd-4758-9886-8c1a0537b8f6"; } ];

	# Users

	users.users.alex = {
		uid = 1000;
		description = "Alex Shpilkin";
		isNormalUser = true;
		extraGroups = [ "wheel" ];
	};
}

{ amd, by-uuid, desktop, lib, pkgs, ... }:

{
	system.stateVersion = "21.11";
	imports = [ amd by-uuid desktop ];

	boot.kernelParams = [ "quiet" ];
	boot.loader.timeout = 0;
	boot.plymouth = {
		enable = true;
		logo = "${pkgs.nixos-icons}/share/icons/hicolor/72x72/apps/nix-snowflake-white.png";
		extraConfig = ''
			DeviceScale=2
		'';
	};
	programs.dconf.profiles.gdm.databases = [{
		settings = {
			"org/gnome/desktop/interface".scaling-factor = 1.5;
			"org/gnome/mutter".experimental-features = [ "scale-monitor-framebuffer" ];
		};
	}];

	boot.extraModprobeConfig = ''
		options cfg80211 ieee80211_regdom="IL"
	'';
	#boot.initrd.kernelModules = [ "amdgpu" ];

	hardware.enableRedistributableFirmware = true;
	hardware.wirelessRegulatoryDatabase = true;

	services.fwupd.enable = true;

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

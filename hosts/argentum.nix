{ by-uuid, config, generic, intel, pkgs, ... }:

let
	kodi-wayland = pkgs.kodi-wayland.withPackages (ps: with ps; [
		radioparadise sendtokodi sponsorblock vfs-libarchive vfs-sftp youtube
	]);

in {
	system.stateVersion = "21.11";
	imports = [ by-uuid generic intel ];

	hardware.enableRedistributableFirmware = true;
	hardware.bluetooth.enable = true;
	boot.initrd.availableKernelModules = [
		"ahci" "rtsx_usb_sdmmc" "sd_mod" "sr_mod" "usbhid" "usb_storage" "xhci_pci"
	];

	# Boot loader

	boot.loader.timeout = 0;
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	boot.initrd.systemd.emergencyAccess = true;
	systemd.services.emergency.serviceConfig.Environment = [ "SYSTEMD_SULOGIN_FORCE=1" ];
	systemd.services.rescue.serviceConfig.Environment = [ "SYSTEMD_SULOGIN_FORCE=1" ];

	boot.kernelParams = [ "quiet" ];
	boot.plymouth.enable = true;

	# Filesystems

	fileSystems."/boot" = {
		partuuid = "ea53b4ba-2d37-4693-87a1-d7a30e36843c";
		fsType = "vfat";
	};

	fileSystems."/" = {
		uuid = "c0360e57-5249-452a-a0cd-4f9fc48863b6";
		fsType = "xfs";
	};

	fileSystems."/home" = {
		uuid = "75e3eeb9-ae88-4f79-957d-836659354abe";
		fsType = "xfs";
	};

	swapDevices = [ { uuid = "40aac296-5972-4e97-9045-799a3c7d8111"; } ];

	# Services

	services.udisks2.enable = true;

	networking.useNetworkd = true;
	networking.useDHCP = true;
	services.avahi.enable = true;
	services.resolved.enable = true;

	security.rtkit.enable = true;
	hardware.pulseaudio.enable = false;
	services.pipewire = {
		enable = true;
		pulse.enable = true;
	};

	services.cage = {
		enable = true;
		program = "${kodi-wayland}/bin/kodi-standalone";
		user = "kiosk";
	};

	# Users

	security.sudo.wheelNeedsPassword = false;

	users.users.${config.services.cage.user} = {
		uid = 1000;
		description = "Kiosk user";
		isNormalUser = true;
		extraGroups = [ "wheel" ];
	};
}

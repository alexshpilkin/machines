{ config, intel, lib, ... }:

let
	inherit (lib) mkDefault;

in {
	imports = [ intel ];

	boot.initrd.availableKernelModules = [
		"ahci" "xhci_pci" "usb_storage" "usbhid" # USB
		"sd_mod" # SD
		"applesmc" # Keyboard backlight (FIXME)
	];

	# disk
	services.fstrim.enable = true;

	# keyboard
	# https://wiki.archlinux.org/title/Apple_Keyboard#hid_apple_module_options
	boot.extraModprobeConfig = ''
		options hid_apple fnmode=2
	'';

	# ports
	services.hardware.bolt.enable = true;

	# screen
	hardware.video.hidpi.enable = mkDefault true;
	boot.loader.systemd-boot.consoleMode = "keep";

	# webcam
	hardware.facetimehd.enable = true;
	hardware.facetimehd.withCalibration = true;

	# wireless
	boot.kernelModules = [ "wl" ];
	boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
}

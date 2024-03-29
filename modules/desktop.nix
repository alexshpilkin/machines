{ fix-gnome-console, generic, lib, pkgs, unfree, ... }:

let
	inherit (builtins) elem;
	inherit (lib) getName;

in {
	imports = [ generic unfree ];

	nixpkgs.allowUnfreePackages = [
		"brother-udev-rule-type1"
		"brscan4"
		"brscan4-etc-files"
	];

	security.pki.certificateFiles = [ ./kindle.pem ];

	hardware.sane = {
		enable = true;
		# brscan5 segfaults
		brscan4 = {
			enable = true;
			netDevices.frater = {
				name = "Frater";
				ip = "192.168.1.16";
				model = "MFC-8880DN";
			};
		};
	};

	services.printing = {
		enable = true;
		drivers = with pkgs; [ foomatic-db-ppds ];
	};

	services.udev.packages = [ pkgs.android-udev-rules ];

	sound.enable = true; # ALSA
	security.rtkit.enable = true;
	hardware.pulseaudio.enable = false;
	services.pipewire = {
		enable = true;
		alsa = { enable = true; support32Bit = true; };
		jack.enable = true;
		pulse.enable = true;
		wireplumber.enable = true;
	};

	networking.networkmanager = { enable = true; enableStrongSwan = true; };

	services.xserver.enable = true;
	services.xserver.displayManager.gdm = { enable = true; wayland = true; };
	services.xserver.displayManager.defaultSession = "gnome";
	services.xserver.desktopManager.gnome.enable = true;
	# https://github.com/NixOS/nixpkgs/issues/32580
	environment.variables.WEBKIT_DISABLE_COMPOSITING_MODE = "1";
}

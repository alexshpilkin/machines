{ config, generic, lib, pkgs, unfree, ... }:

let
	inherit (builtins) elem;
	inherit (lib) getName mkForce;

in {
	imports = [ generic unfree ];

	boot.kernel.sysctl = {
		"kernel.perf_event_paranoid" = 0;
		"kernel.yama.ptrace_scope" = 0;
	};

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

	services.resolved.enable = true;

	services.udev.packages = [ pkgs.android-udev-rules ];

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
	services.displayManager.defaultSession = "gnome";
	services.xserver.desktopManager.gnome.enable = true;
#	# https://github.com/NixOS/nixpkgs/issues/32580
#	environment.variables.WEBKIT_DISABLE_COMPOSITING_MODE = "1";

	services.gnome.gnome-keyring.enable = mkForce false;

	environment.systemPackages = [ config.boot.kernelPackages.perf ];
}

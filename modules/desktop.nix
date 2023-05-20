{ fix-gnome-console, generic, pkgs, ... }:

{
	imports = [ generic ];

	security.pki.certificateFiles = [ ./kindle.pem ];

	services.printing.enable = true;

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

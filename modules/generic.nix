{ pkgs, ... }:

{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	# drivers
	services.printing.drivers = with pkgs; [ foo2zjs ];

	# services
	networking.firewall.enable = false;
	networking.useDHCP = false; # true is deprecated
	services.openssh.enable = true;
	services.pcscd.enable = true; # Yubikey support
	programs.gnupg.agent = { enable = true; enableSSHSupport = true; }; # FIXME

	# programs
	#boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; # FIXME
	programs.nix-ld.enable = true;
	environment.systemPackages = with pkgs; [
		nixos-option # NixOS option reference
		ntfs3g ntfsprogs # NTFS (duh)
		pinentry pinentry-gnome # for GPG (FIXME)
		syncthing # stable user unit paths for Syncthing (FIXME)
		iw iwd dhcpcd # backup networking
	];
}

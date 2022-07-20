{ config, fix-gnome-console, lib, pkgs, ... }:

let
	inherit (lib) mkDefault mkIf mkMerge;

in {
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.settings = {
		substituters = [ "https://nixpkgs-unfree.cachix.org" ];
		trusted-public-keys = [ "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs=" ];
	};
	nixpkgs.overlays = [ fix-gnome-console ];

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
	environment.systemPackages = with pkgs; mkMerge [
		[
			nixos-option # NixOS option reference
			ntfs3g ntfsprogs # NTFS (duh)
			pinentry pinentry-gnome # for GPG (FIXME)
			iw iwd dhcpcd # backup networking
		]
		(mkIf config.documentation.man.enable [
			man-pages man-pages-posix # system referece
		])
	];

	# documentation
	documentation.doc.enable = mkDefault true;
	documentation.info.enable = mkDefault true;
	documentation.man.enable = mkDefault true;
}

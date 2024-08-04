{ config, lib, pkgs, ... }:

let
	inherit (builtins) head length;
	inherit (lib) mkDefault mkIf mkMerge;

in {
	nix.nixPath = mkIf (config.nix.channel.enable) [
		"nixpkgs=${config.nix.registry.nixpkgs.flake}"
		"nixos-config=${config.nix.registry.nixos-config.flake}"
		"/nix/var/nix/profiles/per-user/root/channels"
	];
	nix.settings.auto-optimise-store = true;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.settings = {
		substituters = [
			"https://nixpkgs-unfree.cachix.org"
			"https://numtide.cachix.org"
		];
		trusted-public-keys = [
			"nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
			"numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
		];
	};

	# boot
	boot.resumeDevice = mkIf (length config.swapDevices == 1)
		(head config.swapDevices).device;

	# drivers
	boot.kernelPackages = mkDefault pkgs.linuxPackages_latest;
	hardware.usb-modeswitch.enable = true;

	# services
	networking.firewall.enable = false;
	networking.useDHCP = mkDefault false;
	services.openssh.enable = true;
	services.pcscd.enable = true; # Yubikey support

	# programs
	boot.initrd.systemd.enable = true;
	#boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; # FIXME
	programs.less.lessopen = null;
	programs.nix-ld.enable = true;
	environment.systemPackages = with pkgs; mkMerge [
		[
			nixos-option # NixOS option reference
			ntfs3g ntfsprogs # NTFS (duh)
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

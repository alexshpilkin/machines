{ by-uuid, lib, pkgs, yandex, ... }:

{
	system.stateVersion = "21.11";
	imports = [ by-uuid yandex ];

	# Filesystems

	fileSystems."/" = {
		uuid = "8ad01f0e-3823-44d2-a4d9-8bec8e6edf7c";
		fsType = "ext4";
		options = [ "discard" ];
	};

	# Network

	networking.useDHCP = true;
	networking.useNetworkd = true;

	# Services

	## HTTP server

	services.nginx.enable = true;

	## ACME client

	security.acme = {
		acceptTerms = true;
		defaults.server = "https://acme-staging-v02.api.letsencrypt.org/directory";
	};

	security.acme.certs."moscow.sheaf.site" = {
		email = "certmaster@moscow.sheaf.site";
		webroot = "/var/lib/acme/acme-challenge/";
	};
	services.nginx.virtualHosts."moscow.sheaf.site".locations."/.well-known/acme-challenge/" = {
		root = config.security.acme.certs."moscow.sheaf.site".webroot;
	};

	# Users

	users.extraUsers.root = {
		openssh.authorizedKeys.keys = [
			"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3Pvaf9+XvzdvLRA5CleeC6ph1hI/o3MVwvvI3xQoe7aRNWEPK5WD2J7MzIQnJBZxO7fWwkKBlEzv1NHLEHGUlM/6CwkjzZOh7b4hKSyfe7u9PSamY9dcuPblnEB7jyT10ezZT+6lqlue2dAmsHai+1jF6hoAqlY8jT4vhT2co3cZNtwOnjbrK8GA6rQiVkStIy3xma1goNV/Xl/zeC4M6qG7XXuJbWPY75v35O5QEtd/hwYFMBr6ShA/9OJ45V9qSk+njGkx0h6C0GNF10Y6Gq4J0ApDLVePx0kGWfvRECVhMFtFwRNeiPRKWWOEH7fp/teRYKB03HQFBusAsCdmF openpgp:0xD16143D3"
		];
	};
	users.users.alex = {
		uid = 1000;
		description = "Alex Shpilkin";
		isNormalUser = true;
		extraGroups = [ "wheel" ];
	};
}

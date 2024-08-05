{ acme-swanctl, by-uuid, config, lib, pkgs, yandex, ... }:

let
	prefix = "192.168.7";
	warriorXFRM = 7;

in {
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

	networking.nftables.enable = true;
	networking.firewall.enable = true;
	networking.nat = {
		enable = true;
		externalInterface = "en*";
	};

	# Services

	## DNS recursive resolver

	services.unbound.enable = true;
	services.unbound.settings = {
		server = {
			interface = [ "127.0.0.1" "warrior" ];
			access-control = [ "127.0.0.0/8 allow" "192.168.0.0/16 allow" ];
			private-address = [ "127.0.0.0/8" "192.168.0.0/16" ];
		};
	};

	## HTTP server

	services.nginx.enable = true;
	networking.firewall.allowedTCPPorts = [ 80 ]; # http

	## ACME client

	security.acme = {
		acceptTerms = true;
		defaults.webroot = "/var/lib/acme/acme-challenge/";
	};

	security.acme.certs."moscow.sheaf.site" = {
		email = "certmaster@moscow.sheaf.site";
	};
	services.nginx.virtualHosts."moscow.sheaf.site".locations."/.well-known/acme-challenge/" = {
		root = config.security.acme.certs."moscow.sheaf.site".webroot;
	};

	## IPsec server

	services.strongswan-swanctl.enable = true;
	security.acme.certs."moscow.sheaf.site" = {
		postRun = "${acme-swanctl}/bin/acme-swanctl.sh";
		reloadServices = [ "strongswan-swanctl" ];
	};
	systemd.services.strongswan-swanctl = {
		wants = [ "acme-finished-moscow.sheaf.site.target" ];
		after = [ "acme-finished-moscow.sheaf.site.target" ];
	};
	networking.firewall.allowedUDPPorts = [ 500 4500 ]; # isakmp ipsec-nat-t
	networking.firewall.extraInputRules = "meta l4proto { ah, esp } accept";

	services.strongswan-swanctl.swanctl.pools."warrior" = {
		addrs = "${prefix}.32-${prefix}.254";
		dns = [ "${prefix}.1" ];
	};
	services.strongswan-swanctl.swanctl.connections."warrior" = {
		if_id_in = toString warriorXFRM;
		if_id_out = toString warriorXFRM;
		pools = [ "warrior" ]; # FIXME: Use DHCP?

		rekey_time = "0"; # Windows
		keyingtries = 0; # i.e. infinite

		proposals = [
			"aes256-sha256-modp2048"
			"aes256-sha1-modp1024" # Windows
		];

		local.default = {
			id = "moscow.sheaf.site";
			auth = "pubkey";
			certs = [ "moscow.sheaf.site.pem" ];
		};

		remote.default = {
			auth = "eap-mschapv2";
			eap_id = "%any";
		};

		children."warrior" = {
			mode = "tunnel";
			local_ts = [ "0.0.0.0/0" ];
			life_time = "0"; # Windows
			esp_proposals = [
				"aes256-sha256-modp2048"
				"aes256-sha1" # Windows
			];
		};
	};
	services.strongswan-swanctl.includes = [ "/etc/swanctl/secrets.conf" ];
	systemd.tmpfiles.rules = [ "f /etc/swanctl/secrets.conf 0600 root root" ];
	systemd.network.networks."99-ethernet-default-dhcp".xfrm = [ "warrior" ];
	systemd.network.netdevs."20-warrior" = {
		netdevConfig = { Name = "warrior"; Kind = "xfrm"; };
		xfrmConfig = { InterfaceId = warriorXFRM; };
	};
	systemd.network.networks."20-warrior" = {
		name = "warrior";
		address = [ "${prefix}.1/24" ];
		linkConfig = {
			MTUBytes = "1414"; # FIXME: Not sure that's right.
			Multicast = true;
		};
	};
	networking.firewall.trustedInterfaces = [ "warrior" ];
	networking.nat.internalInterfaces = [ "warrior" ];

	# Software

	documentation.doc.enable = false;
	documentation.info.enable = false;

	environment.systemPackages = [
		config.services.strongswan-swanctl.package # for swanctl
	];

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

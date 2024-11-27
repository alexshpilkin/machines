{ by-uuid, config, frantech, ... }:

{
	system.stateVersion = "24.11";
	imports = [ by-uuid frantech ];

	# Filesystems

	fileSystems."/" = {
		uuid = "de99724c-3fa5-49c6-9157-f5665a13f160";
		fsType = "ext4";
		options = [ "discard" ];
	};

	swapDevices = [ { uuid = "e55d54e6-20f1-4b30-8ee3-9afdd5d2d71a"; } ];

	# Network

	networking.useDHCP = true;
	networking.useNetworkd = true;

	networking.firewall.enable = true;
	networking.nftables.enable = true;

	# Services

	## DNS recursive resolver

	services.unbound.enable = true;
	services.unbound.settings = {
		server = {
			interface = [ "127.0.0.1" ];
			access-control = [ "127.0.0.0/8 allow" "192.168.0.0/16 allow" ];
			private-address = [ "127.0.0.0/8" "192.168.0.0/16" ];
		};
	};

	## Syncthing relay server

	services.syncthing.relay = { enable = true; pools = [ ]; };
	networking.firewall.allowedTCPPorts =
		with config.services.syncthing.relay; [ statusPort port ];

	# Software

	documentation.doc.enable = false;
	documentation.info.enable = false;

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

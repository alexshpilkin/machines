{ by-uuid, config, generic, lib, modulesPath, pkgs, ... }:

# <https://yandex.cloud/ru/docs/compute/operations/image-create/custom-image>

let
	inherit (lib) mkOption;
	headless = "${modulesPath}/profiles/headless.nix";

in {
	imports = [ by-uuid headless generic ];

	nixpkgs.system = "x86_64-linux";

	# Boot

	boot.loader.grub.device = "/dev/vda";
	boot.growPartition = true;
	boot.kernelParams = [ "console=ttyS0,115200" "earlycon" ];

	# Hardware

	boot.initrd.availableKernelModules = [
		"virtio_blk"
		"virtio_net"
		"virtio_pci"
		"virtiofs"
	];
	# FIXME can these actually autodetect?
	boot.initrd.kernelModules = [
		"virtio_balloon"
		"virtio_console"
		"virtio-rng"
	];

	# Services

	# Note cloud-init seems nonfunctional.

	# FIXME why is this necessary?
	systemd.services."serial-getty@ttyS0".enable = true;

	# Filesystems

	fileSystems."/".autoResize = true;

	# Outputs

	system.build.image = import "${pkgs.path}/nixos/lib/make-disk-image.nix" {
		inherit config lib pkgs;
		name = "yandex";
		format = "qcow2";
		partitionTableType = "legacy";
		fsType = config.fileSystems."/".fsType;
		rootGPUID = config.fileSystems."/".uuid;
		additionalSpace = "128M";
	};
}

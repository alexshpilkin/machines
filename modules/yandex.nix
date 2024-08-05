{ by-uuid, config, generic, lib, pkgs, ... }:

# <https://yandex.cloud/ru/docs/compute/operations/image-create/custom-image>

{
	imports = [ by-uuid generic ];

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
	boot.initrd.kernelModules = [
		"virtio_balloon"
		"virtio_console"
		"virtio-rng"
	];

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

{ amd, by-uuid, generic, ... }:

{
	imports = [ amd by-uuid generic ];

	# Boot

	boot.loader.grub.device = "/dev/vda";

	# Hardware

	boot.initrd.availableKernelModules = [
		"ata_piix"
		"sd_mod"
		"sr_mod"
		"uhci_hcd"
		"virtio_blk"
		"virtio_net"
		"virtio_pci"
		"virtio_scsi"
		"virtiofs"
	];
	boot.initrd.kernelModules = [
		"virtio_balloon"
		"virtio_console"
		"virtio-rng"
	];
}

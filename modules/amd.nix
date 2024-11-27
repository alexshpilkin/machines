{ config, lib, ... }:

let
	inherit (lib) mkDefault;

in {
	nixpkgs.system = "x86_64-linux";

	boot.kernelModules = [ "kvm-amd" ];
	hardware.cpu.amd.updateMicrocode =
		mkDefault config.hardware.enableRedistributableFirmware;
}

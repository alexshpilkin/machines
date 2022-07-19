{ config, lib, ... }:

with lib;

{
	nixpkgs.system = "x86_64-linux";

	boot.kernelModules = [ "kvm-intel" ];
	hardware.cpu.intel.updateMicrocode =
		mkDefault config.hardware.enableRedistributableFirmware;
}

{ config, lib, ... }:

let
	inherit (lib) mkDefault;

in {
	nixpkgs.system = "x86_64-linux";

	hardware.cpu.amd.updateMicrocode =
		mkDefault config.hardware.enableRedistributableFirmware;
}

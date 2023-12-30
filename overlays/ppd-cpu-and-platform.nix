final: prev:

{
	power-profiles-daemon = prev.power-profiles-daemon.overrideAttrs (old: {
		patches = old.patches or [] ++ [ (final.fetchpatch {
			url = "https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/merge_requests/127.patch";
			sha256 = "078xa4sw0c1yzl3p8q5rbmy91a0y7zz164mzcyjp6h6nkg4bjylf";
		}) ];
	});
}

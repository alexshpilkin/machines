final: prev:

{
	gnome-console = prev.gnome-console.overrideAttrs (old: {
		patches = old.patches ++ [ (final.fetchpatch {
			url = "https://gitlab.gnome.org/GNOME/console/-/merge_requests/80.patch";
			sha256 = "0w47hxhgyi88yd16pw28rylj58l0xw7y3671pmgs41szxvgs9g17";
		}) ];
	});
}

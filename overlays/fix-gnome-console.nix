final: prev:

{
	gnome-console = prev.gnome-console.overrideAttrs (old: {
		src = final.fetchFromGitLab {
			domain = "gitlab.gnome.org";
			owner = "kepstin";
			repo = "console";
			rev = "bc75ad9b71df3fee877dd030a84c9f2235d24f9c"; # new-colours
			sha256 = "19zb4dpbhzkr4akjgjjn9493acdsnahi86wvzl6jkqn9ghqcsrwh";
		};
	});
}

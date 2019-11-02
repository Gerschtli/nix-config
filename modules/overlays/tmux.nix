self: super:

{
  tmux = super.tmux.overrideAttrs (old: rec {
    name = "tmux-${version}";
    version = "2.8";

    src = super.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = "01918cb0170e07288d3aec624516e6470bf5b7fc";
      sha256 = "1fy87wvxn7r7jzqapvjisc1iizic3kxqk2lv83giqmw1y4g3s7rl";
    };

    postPatch = ''
      sed -i 's/2.8-rc/2.8/' configure.ac
    '';
  });
}

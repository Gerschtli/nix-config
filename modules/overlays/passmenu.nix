self: super:

let
  # see patches/dwm/config.def.h -> dmenucmd
  dmenuCmd = ''dmenu -fn "Ubuntu Mono Nerd Font:size=9" -nb "#222222" -nf "#bbbbbb" -sb "#540303" -sf "#eeeeee"'';
in

{
  pass = super.pass.overrideAttrs (old: {
    postBuild = ''
      sed -i -e 's@ dmenu @ ${dmenuCmd} @g' contrib/dmenu/passmenu
    '';
  });
}

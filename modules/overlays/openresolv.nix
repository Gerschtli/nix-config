self: super:

# Needed to fix filename collisions like:
# collision between `/nix/store/<...>-systemd-239/sbin/resolvconf' and `/nix/store/<...>-openresolv-3.9.0/sbin/resolvconf'
# collision between `/nix/store/<...>-systemd-239/bin/resolvconf' and `/nix/store/<...>-openresolv-3.9.0/bin/resolvconf'

{ openresolv = super.lowPrio super.openresolv; }

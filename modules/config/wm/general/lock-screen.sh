revert() {
    xset -dpms
}

trap revert HUP INT TERM
xset +dpms dpms 3 3 3

i3lock-fancy --nofork --text "" -- scrot --silent --overwrite

revert

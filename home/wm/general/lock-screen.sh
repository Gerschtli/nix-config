revert() {
    xset s off
    xset -dpms
}

trap revert HUP INT TERM
xset s 5
xset +dpms

@lockCommand@

revert

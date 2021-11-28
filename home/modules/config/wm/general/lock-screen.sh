revert() {
    xset -dpms
}

trap revert HUP INT TERM
xset +dpms dpms 3 3 3

@lockCommand@

revert

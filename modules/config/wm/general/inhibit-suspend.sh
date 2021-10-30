# Disable suspend on lid close until screen gets unlocked
systemd-inhibit --what=handle-lid-switch lock-screen

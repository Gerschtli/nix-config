# Manual Setup for radon (Ubuntu 20.04)

```bash
# update and install system packages
sudo apt update
sudo apt upgrade
sudo apt install curl zsh xdm neovim light

# install nix and home-manager setup
curl -L https://nixos.org/nix/install | sh
nix run nixpkgs.wget -c wget -q "https://tobias-happ.de/setup.sh"
chmod +x setup.sh
./setup.sh
rm setup.sh

# download and install UbuntuMono from nerdfonts.com
mkdir ~/.fonts
cd ~/.fonts
# check for latest release
wget -q "https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/UbuntuMono.zip"
unzip UbuntuMono.zip
rm UbuntuMono.zip
fc-cache -fv

# setup default and login shell
chsh -s /bin/zsh
sudo ln -snf bash /bin/sh

# install slock
mkdir -p ~/projects
git cl git@github.com:Gerschtli/slock.git ~/projects/slock
cd ~/projects/slock
nix-shell -p xorg.libX11 xorg.libXrandr xorg.libXext --run "sudo make config.h clean install"

# install display link driver
>> open <https://www.displaylink.com/downloads/ubuntu>
# apply fix (https://support.displaylink.com/knowledgebase/articles/1181623-displaylink-ubuntu-driver-after-recent-x-upgrades)
sudo cat <<EOF > /usr/share/X11/xorg.conf.d/21-displaylink.conf
Section "Device"
  Identifier "DisplayLink"
  Driver "modesetting"
  Option "PageFlip" "false"
EndSection
EOF

# install docker
>> open <https://docs.docker.com/engine/install/ubuntu/>

# add necessary groups
sudo usermod -a -G docker video $USER

# configure sudoers rule
sudo visudo -f hibernate
# insert following line
>> tobias radon=(root:root) NOPASSWD: /usr/bin/systemctl hibernate
```

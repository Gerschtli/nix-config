# Manual Setup for gamer (WSL2 Ubuntu 20.04)

```bash
# update and install system packages
sudo apt update
sudo apt upgrade
sudo apt install zsh

# install nix and home-manager setup
curl -L https://nixos.org/nix/install | sh
nix run nixpkgs.wget -c wget -q "https://tobias-happ.de/setup.sh"
chmod +x setup.sh
./setup.sh
rm setup.sh

# download and install UbuntuMono from nerdfonts.com
>> open <https://github.com/ryanoasis/nerd-fonts/releases/>

# setup login shell
chsh -s /bin/zsh
```

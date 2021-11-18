# Manual Setup for M386 (Ubuntu 18.04)

```bash
# update and install system packages
sudo apt update
sudo apt upgrade
sudo apt install curl zsh

# install nix and home-manager setup

# download and install UbuntuMono from nerdfonts.com

# setup default and login shell
chsh -s /bin/zsh
sudo ln -snf bash /bin/sh

# install docker
>> open <https://docs.docker.com/engine/install/ubuntu/>

# add necessary groups
sudo usermod -a -G docker $USER

# configure inotify watcher
sudo vim /etc/sysctl.d/local.conf
# insert following line
>> fs.inotify.max_user_watches = 524288
```

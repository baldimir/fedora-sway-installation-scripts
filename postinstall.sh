#!/bin/sh

read -r -p "Do you want to install extras? [y/n] " installextras
read -r -p "Do you want to install VPN? [y/n] " installvpn
read -r -p "Do you want to setup wallpapers? [y/n] " setupwallpapers
read -r -p "Do you want to setup default bitrate in PipeWire for audio? If yes, specify the bitrate: " pipewirebitrate
read -r -p "Do you want to setup allowed bitrates in PipeWire for audio? If yes, specify the bitrates (comma separated list): " pipewireallowedbitrates
read -r -p "Do you want to reboot at the end of the installation? [y/n] " rebootattheend

# Update the system
sudo pacman -Syu --noconfirm

# Install rpm-fusion repositories
sudo dnf install \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# Install Sway and other packages that are used in the desktop
sudo pacman -S --noconfirm sway swaylock swayidle bemenu light mako slurp grim kanshi \
     xdg-desktop-portal xdg-desktop-portal-wlr wl-clipboard \
     alacritty vim translate-shell mc htop pavucontrol progress fwupd \
     ttf-ibm-plex awesome-terminal-fonts powerline-fonts \
     playerctl flatpak python-pip ffmpeg \
     libvdpau-va-gl libva-vdpau-driver \ 
     firefox
pip install --user bumblebee-status
pip install --user pulsemixer

# Install from AUR
yay -S --noconfirm j4-dmenu-desktop, wdisplays

# TODO find out what to do about
# pulseaudio-utils

# Enable flathub
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if [ $PWD != $HOME ] 
then
    # Copy Sway configuration
    mkdir -p ~/.config/sway/
    cp .config/sway/* ~/.config/sway/
    sudo chmod +x ~/.config/sway/autostart.sh
    mkdir -p ~/.local/bin
    cp .local/bin/sway-run ~/.local/bin/sway-run
    sudo chmod +x ~/.local/bin/sway-run
    mkdir -p ~/.config/kanshi
    cp .config/kanshi/config ~/.config/kanshi/config
    mkdir -p ~/.config/mako
    cp .config/mako/config ~/.config/mako/config

    # Copy shell configuration
    mkdir -p ~/.bashrc.d/
    cp .bashrc.d/* ~/.bashrc.d/
    
    # Copy Midnight Commander configuration
    mkdir -p ~/.config/mc/
    cp .config/mc/* ~/.config/mc/

    # Copy default applications configuration
    cp .config/mimeapps.list ~/.config/
    
    # Copy Alacritty configuration
    mkdir -p ~/.config/alacritty
    cp .config/alacritty/* ~/.config/alacritty/
    cp .dircolors ~/.dircolors
fi

# TODO
# xdg-settings set default-web-browser firefox

# Install extras
sudo chmod +x ./extras.sh
case $installextras in 
    [yY][eE][sS]|[yY]) sh ./extras.sh;;
    *) echo "Skipping extras.";;
esac    

# Install VPN
sudo chmod +x ./vpninstall.sh
case $installvpn in 
    [yY][eE][sS]|[yY]) sh ./vpninstall.sh;;
    *) echo "Skipping VPN installation."
esac

# Setup wallpapers
sudo chmod +x wallpapers.sh
case $setupwallpapers in 
    [yY][eE][sS]|[yY]) sh ./wallpapers.sh;;
    *) echo "Skipping wallpapers setup.";;
esac

# Setup Pipewire
if [ -z "$pipewirebitrate" ]
then 
    sudo sed -i -e "s/#default.clock.rate          = 48000/default.clock.rate          = $pipewirebitrate/g" /usr/share/pipewire/pipewire.conf
fi
if [ -z "$pipewireallowedbitrates" ]
then 
    sudo sed -i -e "s/#default.clock.allowed-rates = \[ 48000 \]/default.clock.allowed-rates = \[ $pipewireallowedbitrates \]/g" /usr/share/pipewire/pipewire.conf
fi

# Reboot
case $rebootattheend in
    [yY][eE][sS]|[yY]) systemctl reboot;;
    *) echo "Installation done.";;
esac

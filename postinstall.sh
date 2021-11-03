#!/bin/sh

read -r -p "Do you want to install extras? [y/n] " installextras
read -r -p "Do you want to install VPN? [y/n] " installvpn
read -r -p "Do you want to install RPMs from customrpms directory? [y/n] " installcustomrpms
read -r -p "What is your timezone? " currenttimezone
read -r -p "Do you want to setup wallpapers? [y/n] " setupwallpapers
read -r -p "Do you want to setup default bitrate in PipeWire for audio? If yes, specify the bitrate: " pipewirebitrate
read -r -p "Do you want to setup allowed bitrates in PipeWire for audio? If yes, specify the bitrates (comma separated list): " pipewireallowedbitrates
read -r -p "Do you want to reboot at the end of the installation? [y/n] " rebootattheend

# Update the system
sudo dnf upgrade -y

# Install additional package groups
sudo dnf groupinstall "Standard" "Common NetworkManager Submodules" "Hardware Support" "Multimedia" "Printing Support" -y

# Install rpm-fusion repositories
sudo dnf install \
    https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y

# Install Sway and other packages that are used in the desktop
sudo dnf install sway swaylock swayidle bemenu j4-dmenu-desktop light mako slurp grim kanshi wdisplays \
     xdg-desktop-portal xdg-desktop-portal-wlr wl-clipboard pulseaudio-utils \ 
     vim translate-shell mc htop pavucontrol progress fwupd \ 
     ibm-plex-mono-fonts fontawesome-fonts powerline-fonts \ 
     playerctl flatpak python3-pip \ 
     gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg \ 
     libvdpau-va-gl libva-vdpau-driver \ 
     firefox firefox-wayland -y
pip install --user bumblebee-status
pip install --user pulsemixer

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

xdg-settings set default-web-browser firefox-wayland

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

# Install custom RPMs
case $installcustomrpms in 
    [yY][eE][sS]|[yY]) sudo dnf localinstall ./customrpms/*.rpm -y;;
    *) echo "Skipping installation of RPMs from directory customrpms.";;
esac

sudo timedatectl set-timezone $currenttimezone

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

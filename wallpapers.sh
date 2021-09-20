#!/bin/sh

sudo cp wallpapers/* /usr/share/backgrounds/

lockscreenimages=$(find /usr/share/backgrounds/ -type f -printf "%f\n" | grep 'lockscreen')
sed -i -e "s/set \$swaylockcmd swaylock -f -c 000000/set \$swaylockcmd swaylock -f -i \/usr\/share\/backgrounds\/${lockscreenimages[0]} -s fit -c 000000/g" ~/.config/sway/config

desktopimages=$(find /usr/share/backgrounds/ -type f -printf "%f\n" | grep 'desktop')
sed -i -e "s/output \* bg \/usr\/share\/backgrounds\/default.png fill/output \* bg \/usr\/share\/backgrounds\/${desktopimages[0]} fit #000000/g" ~/.config/sway/config

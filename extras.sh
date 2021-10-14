#!/bin/sh

sudo chmod +x downloadbitwardencli.sh
sh ./downloadbitwardencli.sh
mv bw ~/.local/bin/bw

flatpak install flathub org.signal.Signal \
	com.jetbrains.IntelliJ-IDEA-Community \
	org.libreoffice.LibreOffice \
	org.gnome.Boxes \
	org.chromium.Chromium \
	org.videolan.VLC \
        org.gnome.Evince \
        com.github.weclawl.ImageRoll -y	

curl -s "https://get.sdkman.io" | bash

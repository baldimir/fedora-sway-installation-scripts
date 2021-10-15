#!/bin/sh

swaymsg "workspace 1"
exec firefox-wayland &
sleep 3s
exec alacritty &
sleep 0.5s
swaymsg "[app_id=Alacritty] resize set width 1050px"
swaymsg "[app_id=Alacritty] splitv"
flatpak run org.signal.Signal &

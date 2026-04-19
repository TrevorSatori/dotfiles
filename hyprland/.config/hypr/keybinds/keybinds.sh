#!/bin/zsh

folder="$HOME/.config/hypr/keybinds"
keybinds="$folder/keybinds.txt"

keybinds1=$(cat "$keybinds")

# Use rofi to display the keybinds
echo "$keybinds1" | rofi -dmenu -theme "$folder/keybinds.rasi" -p "Keybinds"

# DWM

My DWM build

# install 

1. clone the repo
2. cd inside repo
3. sudo make install
4. profit 

# Patches Used

1. Cycle Layouts - switch between all layouts with (Mod+ctrl+,) or (Mod+ctrl+.)
2. Full Gaps - add gaps between windows as well as around edges of screen
3. Hide Vacant Tags - hide unused workspaces to avoid seeing numerous unused tags
4. Steam - stops steam login window from sliding around

# Controls

- Mod + return (spawn terminal)
- Mod + shift + return (swap windows)
- Mod + Shift + c (close window)
- Mod + Shift + q (quit DWM)
- Mod + p (spawn rofi)
- Mod + o (spawn code)
- Mod + u (spawn Spotify)
- Mod + ctrl + (, or .) cycle layouts

# Updates 

If changes are desired, you can edit config.def.h. For changes to take effect, remove config.h then while inside dwm repo type "sudo make install".

# Notes

It is worth mentioning I am using alacritty for my terminal & rofi for application searching.
If you want the commands for terminal and rofi to work these must be installed (sudo pacman -S rofi) (sudo pacman -S alacritty)
otherwise you will need to change inside of source config.def.h. Finally

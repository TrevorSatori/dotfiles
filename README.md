# dotfiles

My entire window manager build. 
Alacritty config
nvim config
picom config

# install 
1. clone the repo
2. cd inside dwm
3. sudo make install
4. cd inside dwmblocks
5. sudo make install
6. For Neovim, Alacritty & Picom, make sure to add files to .config directory
# Putting All Together

Once make install for dwm & dwm blocks is complete, we need a way to activate these programs

1. in home dir (~) if .xinitrc file doesn't exist, create one (touch .xinitrc).
2. inside .xinitrc add the following 2 lines to the end of file.  
dwmblocks &
exec dwm

Once that is done you can type "startx" into a terminal & your window manager will be ready to go. 

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

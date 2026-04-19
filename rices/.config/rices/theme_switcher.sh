#!/bin/zsh

THEME_NAME="$1"
RICE_DIR="$HOME/.config/rices"
THEME_DIR="$RICE_DIR/$THEME_NAME"
CURRENT_LINK="$RICE_DIR/current"

restart_waybar() {
  # Kill any existing waybar process and start fresh quickly.
  pkill -x waybar 2>/dev/null || true
  for _ in {1..20}; do
    pgrep -x waybar >/dev/null 2>&1 || break
    sleep 0.05
  done
  waybar >/dev/null 2>&1 &!
}

set_wallpaper() {
  local wall=""
  local ext
  for ext in png jpg jpeg; do
    if [ -f "$CURRENT_LINK/wallpaper.$ext" ]; then
      wall="$CURRENT_LINK/wallpaper.$ext"
      break
    fi
  done

  [ -z "$wall" ] && return 0

  if ! pgrep -x awww-daemon >/dev/null 2>&1; then
    awww-daemon >/dev/null 2>&1 &!
    sleep 0.2
  fi

  timeout 5 awww img "$wall" --transition-type wipe --transition-duration 1 >/dev/null 2>&1 || true
}

# Sanity check
if [ ! -d "$THEME_DIR" ]; then
  echo "❌ Theme '$THEME_NAME' not found in $RICE_DIR"
  exit 1
fi

echo "🎨 Switching to theme: $THEME_NAME"

# Update 'current' symlink
rm -f "$CURRENT_LINK"
ln -s "$THEME_DIR" "$CURRENT_LINK"

# 🎮 Hyprland
hyprctl reload

# 🧊 Waybar
if [ -f "$CURRENT_LINK/waybar_style.css" ]; then
  ln -sf "$CURRENT_LINK/waybar_style.css" "$HOME/.config/waybar/style.css"
  restart_waybar
fi

# 🎨 Rofi
if [ -f "$CURRENT_LINK/rofi_colors.rasi" ]; then
  ln -sf "$CURRENT_LINK/rofi_colors.rasi" "$HOME/.config/rofi/colors.rasi"
fi
if [ -f "$CURRENT_LINK/rofi.rasi" ]; then
  ln -sf "$CURRENT_LINK/rofi.rasi" "$HOME/.config/rofi/menu.rasi"
fi

# 🐱 Kitty theme
if [ -f "$CURRENT_LINK/kitty_theme.conf" ]; then
  ln -sf "$CURRENT_LINK/kitty_theme.conf" "$HOME/.config/kitty/current-theme.conf"
fi

# 🖼 Wallpaper (awww)
set_wallpaper

# 🧠 Fastfetch logo
for ext in png jpg; do
  if [ -f "$CURRENT_LINK/fastfetch_wallpaper.$ext" ]; then
    echo "Fastfetch logo set to: $CURRENT_LINK/fastfetch_wallpaper.$ext"
    break
  fi
done

echo "✅ Theme '$THEME_NAME' applied."

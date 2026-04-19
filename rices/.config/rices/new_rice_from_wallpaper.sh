#!/bin/zsh

set -euo pipefail

RICE_DIR="$HOME/.config/rices"
CURRENT_LINK="$RICE_DIR/current"
SCRIPT_NAME="$(basename "$0")"

usage() {
  echo "Usage: $SCRIPT_NAME <wallpaper_image> [rice_name]"
  echo "Example: $SCRIPT_NAME ~/Pictures/wall.jpg ocean_night"
}

sanitize_name() {
  local input="$1"
  local out
  out="$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+//; s/_+$//; s/__+/_/g')"
  [[ -z "$out" ]] && out="rice_$(date +%Y%m%d_%H%M%S)"
  echo "$out"
}

hex_to_rgb() {
  local hex="${1#\#}"
  local r=$((16#${hex[1,2]}))
  local g=$((16#${hex[3,4]}))
  local b=$((16#${hex[5,6]}))
  echo "$r $g $b"
}

luma() {
  local rgb r g b
  rgb=($(hex_to_rgb "$1"))
  r="${rgb[1]}"
  g="${rgb[2]}"
  b="${rgb[3]}"
  echo $(((299 * r + 587 * g + 114 * b) / 1000))
}

saturation() {
  local rgb r g b max min
  rgb=($(hex_to_rgb "$1"))
  r="${rgb[1]}"
  g="${rgb[2]}"
  b="${rgb[3]}"
  max=$r
  (( g > max )) && max=$g
  (( b > max )) && max=$b
  min=$r
  (( g < min )) && min=$g
  (( b < min )) && min=$b
  echo $((max - min))
}

to_hex() {
  printf "#%02X%02X%02X\n" "$1" "$2" "$3"
}

adjust_color() {
  local hex="$1"
  local delta="$2"
  local rgb r g b
  rgb=($(hex_to_rgb "$hex"))
  r=$((rgb[1] + delta))
  g=$((rgb[2] + delta))
  b=$((rgb[3] + delta))
  (( r < 0 )) && r=0
  (( g < 0 )) && g=0
  (( b < 0 )) && b=0
  (( r > 255 )) && r=255
  (( g > 255 )) && g=255
  (( b > 255 )) && b=255
  to_hex "$r" "$g" "$b"
}

pick_template_dir() {
  if [[ -L "$CURRENT_LINK" && -d "$CURRENT_LINK" ]]; then
    if [[ -f "$CURRENT_LINK/rofi_colors.rasi" && -f "$CURRENT_LINK/kitty_theme.conf" && -f "$CURRENT_LINK/waybar_style.css" && -f "$CURRENT_LINK/hypr.conf" && -f "$CURRENT_LINK/hyprlock_colors.conf" ]]; then
      echo "$CURRENT_LINK"
      return
    fi
  fi

  local fallback="$RICE_DIR/blue_anonymous"
  if [[ -d "$fallback" ]]; then
    echo "$fallback"
    return
  fi

  echo "❌ Could not find template rice. Need 'current' or 'blue_anonymous' with rofi/kitty/waybar/hypr/hyprlock files."
  exit 1
}

get_rofi_color() {
  local file="$1"
  local key="$2"
  awk -F'#' -v k="$key" '
    $0 ~ k {
      gsub(/[ ;\t]/, "", $2)
      print "#" toupper(substr($2,1,6))
      exit
    }
  ' "$file"
}

replace_color_everywhere() {
  local file="$1"
  local from="$2"
  local to="$3"
  perl -0777 -i -pe "s/\Q$from\E/$to/ig" "$file"
}

set_hyprlock_var() {
  local file="$1"
  local key="$2"
  local hex="${3#\#}"
  local tmp_file="$file.tmp"

  awk -v key="$key" -v hex="$hex" '
    BEGIN { pattern = "^\\$" key "[[:space:]]*=" }
    $0 ~ pattern {
      print "$" key " = rgb(" tolower(hex) ")"
      next
    }
    { print }
  ' "$file" > "$tmp_file"

  mv "$tmp_file" "$file"
}

if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "" ]]; then
  usage
  exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
  echo "❌ 'magick' not found. Install ImageMagick first."
  exit 1
fi

IMAGE_INPUT="$1"
IMAGE_PATH="$(readlink -f "$IMAGE_INPUT" 2>/dev/null || true)"

if [[ -z "$IMAGE_PATH" || ! -f "$IMAGE_PATH" ]]; then
  echo "❌ Wallpaper image not found: $IMAGE_INPUT"
  exit 1
fi

if [[ -n "${2:-}" ]]; then
  RICE_NAME="$(sanitize_name "$2")"
else
  base="$(basename "$IMAGE_PATH")"
  stem="${base%.*}"
  RICE_NAME="$(sanitize_name "${stem}_anonymous")"
fi

TARGET_DIR="$RICE_DIR/$RICE_NAME"
if [[ -e "$TARGET_DIR" ]]; then
  echo "❌ Rice already exists: $TARGET_DIR"
  exit 1
fi

mkdir -p "$TARGET_DIR"

TEMPLATE_DIR="$(pick_template_dir)"
cp -f "$TEMPLATE_DIR/rofi_colors.rasi" "$TARGET_DIR/rofi_colors.rasi"
cp -f "$TEMPLATE_DIR/kitty_theme.conf" "$TARGET_DIR/kitty_theme.conf"
cp -f "$TEMPLATE_DIR/waybar_style.css" "$TARGET_DIR/waybar_style.css"
cp -f "$TEMPLATE_DIR/hypr.conf" "$TARGET_DIR/hypr.conf"
cp -f "$TEMPLATE_DIR/hyprlock_colors.conf" "$TARGET_DIR/hyprlock_colors.conf"

ext="${IMAGE_PATH##*.}"
ext="$(echo "$ext" | tr '[:upper:]' '[:lower:]')"
case "$ext" in
  jpg|jpeg|png) ;;
  *) ext="jpg" ;;
esac
cp -f "$IMAGE_PATH" "$TARGET_DIR/wallpaper.$ext"

palette_lines=("${(@f)$(magick "$IMAGE_PATH" -alpha off -resize 256x256 -colors 8 -format "%c\n" histogram:info: | \
  awk '
    {
      if (match($0, /^[[:space:]]*([0-9]+)/, a) && match($0, /#([0-9A-Fa-f]{6})/, b)) {
        printf "%d #%s\n", a[1], toupper(b[1])
      }
    }' | sort -nr)}")

if (( ${#palette_lines[@]} == 0 )); then
  echo "❌ Could not extract colors from image."
  exit 1
fi

typeset -a palette_colors
for line in "${palette_lines[@]}"; do
  palette_colors+=("${line##* }")
done

bg="${palette_colors[1]}"
fg="${palette_colors[1]}"
lowest=999
highest=-1
accent=""
best_sat=-1

for c in "${palette_colors[@]}"; do
  lum="$(luma "$c")"
  sat="$(saturation "$c")"

  if (( lum < lowest )); then
    lowest="$lum"
    bg="$c"
  fi
  if (( lum > highest )); then
    highest="$lum"
    fg="$c"
  fi
  if [[ "$c" != "$bg" && "$c" != "$fg" ]] && (( sat > best_sat )); then
    best_sat="$sat"
    accent="$c"
  fi
done

[[ -z "$accent" ]] && accent="${palette_colors[2]:-$fg}"
[[ -z "$accent" ]] && accent="#5EA1FF"

# Guard contrast for readable text
if (( $(luma "$fg") - $(luma "$bg") < 120 )); then
  if (( $(luma "$bg") < 128 )); then
    fg="#F2F2F2"
  else
    fg="#141414"
  fi
fi

bg_alt="$(adjust_color "$bg" 12)"

template_bg="$(get_rofi_color "$TEMPLATE_DIR/rofi_colors.rasi" "background")"
template_bg_alt="$(get_rofi_color "$TEMPLATE_DIR/rofi_colors.rasi" "background-alt")"
template_fg="$(get_rofi_color "$TEMPLATE_DIR/rofi_colors.rasi" "foreground")"
template_accent="$(get_rofi_color "$TEMPLATE_DIR/rofi_colors.rasi" "selected")"

[[ -z "$template_bg" ]] && template_bg="#141414"
[[ -z "$template_bg_alt" ]] && template_bg_alt="#1D1D1D"
[[ -z "$template_fg" ]] && template_fg="#FFFFFF"
[[ -z "$template_accent" ]] && template_accent="#18CBEF"

replace_color_everywhere "$TARGET_DIR/rofi_colors.rasi" "$template_bg" "$bg"
replace_color_everywhere "$TARGET_DIR/rofi_colors.rasi" "$template_bg_alt" "$bg_alt"
replace_color_everywhere "$TARGET_DIR/rofi_colors.rasi" "$template_fg" "$fg"
replace_color_everywhere "$TARGET_DIR/rofi_colors.rasi" "$template_accent" "$accent"

replace_color_everywhere "$TARGET_DIR/kitty_theme.conf" "$template_bg" "$bg"
replace_color_everywhere "$TARGET_DIR/kitty_theme.conf" "$template_fg" "$fg"
replace_color_everywhere "$TARGET_DIR/kitty_theme.conf" "$template_accent" "$accent"

replace_color_everywhere "$TARGET_DIR/waybar_style.css" "$template_bg" "$bg"
replace_color_everywhere "$TARGET_DIR/waybar_style.css" "$template_fg" "$fg"
replace_color_everywhere "$TARGET_DIR/waybar_style.css" "$template_accent" "$accent"

set_hyprlock_var "$TARGET_DIR/hyprlock_colors.conf" "color" "$fg"
set_hyprlock_var "$TARGET_DIR/hyprlock_colors.conf" "input_outer_color" "$accent"
set_hyprlock_var "$TARGET_DIR/hyprlock_colors.conf" "input_inner_color" "$bg_alt"
set_hyprlock_var "$TARGET_DIR/hyprlock_colors.conf" "input_font_color" "$fg"

template_accent_rgba="${template_accent#\#}ff"
accent_rgba="${accent#\#}ff"
replace_color_everywhere "$TARGET_DIR/hypr.conf" "$template_accent_rgba" "$accent_rgba"

echo "✅ New rice created: $TARGET_DIR"
echo "   wallpaper: $TARGET_DIR/wallpaper.$ext"
echo "   bg: $bg | fg: $fg | accent: $accent"
echo
echo "Apply now:"
echo "  zsh \"$RICE_DIR/theme_switcher.sh\" \"$RICE_NAME\""

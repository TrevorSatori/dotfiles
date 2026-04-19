#!/bin/zsh

RICE_DIR="$HOME/.config/rices"
THEME_SWITCHER="$RICE_DIR/theme_switcher.sh"
ROFI_THEME="$HOME/.config/rofi/theme_switcher_preview.rasi"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/rofi-theme-previews"
PREVIEW_CACHE_VERSION="uniform-v1"
PREVIEW_WIDTH=512
PREVIEW_HEIGHT=512

# Get only directories, exclude 'current'
theme_folders=()

for dir in "$RICE_DIR"/*(/); do
  folder="${dir##*/}"
  [[ "$folder" == "current" ]] && continue
  theme_folders+=("$folder")
done
theme_folders=("${(@on)theme_folders}")

if (( ${#theme_folders[@]} == 0 )); then
  echo "❌ No themes found in $RICE_DIR"
  exit 1
fi

mkdir -p "$CACHE_DIR"

find_preview_image() {
  local theme_dir="$1"
  local candidate
  local -a names=("preview" "wallpaper" "wall" "background")
  local -a exts=("png" "jpg" "jpeg" "webp")

  for name in "${names[@]}"; do
    for ext in "${exts[@]}"; do
      candidate="$theme_dir/$name.$ext"
      [[ -f "$candidate" ]] && { echo "$candidate"; return; }
    done
  done

  for ext in "${exts[@]}"; do
    candidate=("$theme_dir"/*.$ext(N[1]))
    [[ -n "$candidate" ]] && { echo "$candidate"; return; }
  done
}

build_preview() {
  local src="$1"
  local out="$2"
  local cmd=""

  if command -v magick >/dev/null 2>&1; then
    cmd="magick"
  elif command -v convert >/dev/null 2>&1; then
    cmd="convert"
  fi

  if [[ -z "$cmd" ]]; then
    cp -f "$src" "$out"
    return
  fi

  "$cmd" "$src" \
    -auto-orient \
    -resize "${PREVIEW_WIDTH}x${PREVIEW_HEIGHT}^" \
    -gravity center \
    -extent "${PREVIEW_WIDTH}x${PREVIEW_HEIGHT}" \
    "$out" >/dev/null 2>&1
}

build_placeholder_preview() {
  local out="$1"
  local cmd=""

  if command -v magick >/dev/null 2>&1; then
    cmd="magick"
  elif command -v convert >/dev/null 2>&1; then
    cmd="convert"
  fi

  if [[ -z "$cmd" ]]; then
    return 1
  fi

  "$cmd" -size "${PREVIEW_WIDTH}x${PREVIEW_HEIGHT}" xc:"#1d1f28" \
    -fill "#7aa2f7" \
    -gravity center \
    -pointsize 28 \
    -annotate 0 "NO PREVIEW" \
    "$out" >/dev/null 2>&1
}

emit_rofi_entries() {
  local theme theme_dir preview_image theme_stamp preview_stamp cache_image

  for theme in "${theme_folders[@]}"; do
    theme_dir="$RICE_DIR/$theme"
    preview_image="$(find_preview_image "$theme_dir")"
    theme_stamp="$(stat -c '%Y' "$theme_dir" 2>/dev/null || echo 0)"
    cache_image="$CACHE_DIR/${theme}_${theme_stamp}_${PREVIEW_CACHE_VERSION}.png"

    if [[ -n "$preview_image" ]]; then
      preview_stamp="$(stat -c '%Y' "$preview_image" 2>/dev/null || echo 0)"
      cache_image="$CACHE_DIR/${theme}_${preview_stamp}_${PREVIEW_CACHE_VERSION}.png"
      [[ ! -f "$cache_image" ]] && build_preview "$preview_image" "$cache_image"
    else
      cache_image="$CACHE_DIR/${theme}_${PREVIEW_CACHE_VERSION}_placeholder.png"
      if [[ ! -f "$cache_image" ]]; then
        build_placeholder_preview "$cache_image" || cache_image=""
      fi
    fi

    if [[ -n "$cache_image" && -f "$cache_image" ]]; then
      printf '%s\0icon\x1f%s\n' "$theme" "$cache_image"
    else
      printf '%s\n' "$theme"
    fi
  done
}

CHOICE_INDEX=$(
  emit_rofi_entries | rofi -dmenu -show-icons -p "" -format i \
    -theme "$ROFI_THEME" \
    -theme-str "listview { columns: 3; lines: 3; } window { width: 620px; }"
)

# Run if valid
if [[ "$CHOICE_INDEX" =~ '^[0-9]+$' ]]; then
  CHOICE="${theme_folders[$((CHOICE_INDEX + 1))]}"
fi

if [[ -n "$CHOICE" && -d "$RICE_DIR/$CHOICE" ]]; then
  "$THEME_SWITCHER" "$CHOICE"
else
  echo "❌ Invalid selection or theme not found."
fi


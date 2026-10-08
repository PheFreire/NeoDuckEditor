#!/bin/sh
# Mostra uma imagem no kitty ocupando no máximo <porcentagem> da janela, centralizada.
# A imagem é redimensionada com sips (filtro de alta qualidade) para o tamanho final em
# pixels e exibida 1:1, sem o kitty escalar (a escala do kitty é linear e borra).
# Uso: image-view.sh <imagem> <porcentagem>

img=$1
pct=$2
cols=$(tput cols)
rows=$(($(tput lines) - 1)) # última linha fica para o --hold

# Sem sips (Linux): deixa o kitty escalar dentro da área
if ! command -v sips >/dev/null 2>&1; then
  w=$((cols * pct / 100)); h=$((rows * pct / 100))
  exec kitten icat --hold --scale-up --place "${w}x${h}@$(((cols - w) / 2))x$(((rows - h) / 2))" "$img"
fi

size=$(kitten icat --print-window-size)
win_w=${size%x*}
win_h=${size#*x}
cell_h=$((win_h / (rows + 1)))
box_w=$((win_w * pct / 100))
box_h=$((win_h * pct / 100))

img_w=$(sips -g pixelWidth "$img" 2>/dev/null | awk '/pixelWidth/ { print $2 }')
img_h=$(sips -g pixelHeight "$img" 2>/dev/null | awk '/pixelHeight/ { print $2 }')

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
out=$img
new_h=$img_h

if [ -n "$img_w" ] && [ -n "$img_h" ]; then
  # Cabe na área mantendo a proporção
  if [ $((img_w * box_h)) -gt $((img_h * box_w)) ]; then
    new_w=$box_w; new_h=$((img_h * box_w / img_w))
  else
    new_h=$box_h; new_w=$((img_w * box_h / img_h))
  fi
  if sips -s format png -z "$new_h" "$new_w" "$img" --out "$tmp_dir/view.png" >/dev/null 2>&1; then
    out=$tmp_dir/view.png
  fi
fi

# Centraliza na vertical descendo o cursor, o --align centraliza na horizontal
img_rows=$(((new_h + cell_h - 1) / cell_h))
top=$(((rows - img_rows) / 2))
clear
[ "$top" -gt 0 ] && printf "%${top}s" "" | tr ' ' '\n'
kitten icat --hold --align=center "$out"

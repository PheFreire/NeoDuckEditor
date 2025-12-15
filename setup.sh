#!/bin/bash

log() {
  echo -e "\033[1;34m$1\033[0m"
}

error() {
  echo -e "\033[1;31m$1\033[0m"
}

log "======================================================="
log "🔧 Iniciando setup do ambiente Neovim personalizado..."
log "======================================================="

log "📦 Verificando instalação do 'catimg'..."
if ! command -v catimg &> /dev/null; then
  log "📥 Instalando 'catimg'..."
  apt-get update && apt-get install -y catimg
  log "✅ catimg instalado com sucesso."
else
  log "✅ catimg já está instalado."
fi
log "----------------------------------------------"

log "📦 Verificando instalação do 'FiraCode Nerd Font' ''..."
FONT_DIR="$HOME/.local/share/fonts"
FONT_NAME="FiraCode"
FONT_FILE="$FONT_DIR/${FONT_NAME} Regular Nerd Font Complete.ttf"

if [ ! -f "$FONT_FILE" ]; then
  log "📥 Baixando e instalando FiraCode Nerd Font..."
  mkdir -p "$FONT_DIR"
  wget -q -O "$FONT_DIR/FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
  unzip -o "$FONT_DIR/FiraCode.zip" -d "$FONT_DIR" > /dev/null
  rm "$FONT_DIR/FiraCode.zip"
  fc-cache -fv > /dev/null
  log "✅ FiraCode Nerd Font instalada com sucesso."
else
  log "✅ FiraCode Nerd Font já está instalada."
fi

log "📦 Verificando instalação do 'codex'..."
if ! command -v codex &> /dev/null; then
  log "📥 Instalando 'codex'..."
  npm i -g @openai/codex
  log "✅ codex instalado com sucesso."
else
  log "✅ codex já está instalado."
fi

log "======================================================="
log "🎉 Setup finalizado com sucesso!"
log "======================================================="

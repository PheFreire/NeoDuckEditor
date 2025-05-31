#!/bin/bash

log() {
  echo -e "\033[1;34m$1\033[0m"
}

error() {
  echo -e "\033[1;31m$1\033[0m"
}

log ""
log "🔧 Iniciando setup do ambiente Neovim personalizado..."
log "=============================================="

# Atualiza PATH para garantir acesso ao cargo/rustup
export PATH="$HOME/.cargo/bin:$PATH"

# Instala catimg se necessário
log "📦 Verificando instalação do 'catimg'..."
if ! command -v catimg &> /dev/null; then
  log "📥 Instalando 'catimg'..."
  apt-get update && apt-get install -y catimg
  log "✅ catimg instalado com sucesso."
else
  log "✅ catimg já está instalado."
fi
log "----------------------------------------------"

log "🎉 Setup finalizado com sucesso!"
log ""

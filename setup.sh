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

# Instala pyright
log "📦 Instalando 'pyright' via pip..."
pip install --no-cache-dir pyright
log "✅ pyright instalado com sucesso."
log "----------------------------------------------"

# Instala rustup se necessário e adiciona rust-analyzer
log "⚙️ Verificando rustup..."
if ! command -v rustup &> /dev/null; then
  log "📥 rustup não encontrado. Instalando..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
  log "✅ rustup instalado com sucesso."
else
  log "✅ rustup já está instalado."
fi

log "🔧 Instalando rust-analyzer..."
rustup component add rust-analyzer || error "❌ Falha ao instalar rust-analyzer"
log "✅ rust-analyzer disponível."
log "----------------------------------------------"

log "🎉 Setup finalizado com sucesso!"
log ""

#!/bin/bash
# Instala as skills reels-felipe + premiere-base e tudo que elas usam (macOS).
# Uso: ./install.sh   (rode de dentro da pasta clonada; pode rodar de novo sem problema)
set -e
cd "$(dirname "$0")"
REPO="$(pwd)"
BIN="$HOME/.local/bin"
SKILLS="$HOME/.claude/skills"
ok(){ printf '  \033[32m✓\033[0m %s\n' "$1"; }
warn(){ printf '  \033[33m!\033[0m %s\n' "$1"; }

[ "$(uname)" = "Darwin" ] || { echo "Só funciona no macOS (os scripts usam Swift/AppKit e afconvert)."; exit 1; }
ARCH=$(uname -m); [ "$ARCH" = "arm64" ] || ARCH=amd64
mkdir -p "$BIN" "$SKILLS"

echo "1. Skills"
for s in premiere-base reels-felipe; do
  dst="$SKILLS/$s"
  if [ -L "$dst" ]; then rm "$dst"
  elif [ -e "$dst" ]; then mv "$dst" "$dst.antiga-$(date +%Y%m%d%H%M%S)"; warn "$s já existia: renomeei a antiga para $dst.antiga-*"
  fi
  ln -s "$REPO/skills/$s" "$dst"; ok "$s → $dst (link para o repo; git pull atualiza)"
done

echo "2. Ferramentas de linha de comando"
xcode-select -p >/dev/null 2>&1 && ok "Xcode Command Line Tools (swift)" || { warn "Faltam as Command Line Tools: rodando xcode-select --install (aceite a janela e rode este script de novo)"; xcode-select --install || true; }
command -v python3 >/dev/null && ok "python3" || warn "python3 não encontrado (vem com as Command Line Tools)"

if [ ! -x "$BIN/yt-dlp" ]; then
  if command -v brew >/dev/null; then brew install yt-dlp && ln -sf "$(brew --prefix)/bin/yt-dlp" "$BIN/yt-dlp"
  else curl -fL -o "$BIN/yt-dlp" https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos && chmod +x "$BIN/yt-dlp"; fi
fi
ok "yt-dlp em $BIN/yt-dlp"

for t in ffmpeg ffprobe; do
  if [ ! -x "$BIN/$t" ]; then
    if command -v brew >/dev/null; then brew list ffmpeg >/dev/null 2>&1 || brew install ffmpeg; ln -sf "$(brew --prefix)/bin/$t" "$BIN/$t"
    else
      tmp=$(mktemp -d); curl -fL -o "$tmp/$t.zip" "https://ffmpeg.martin-riedl.de/redirect/latest/macos/$ARCH/release/$t.zip"
      unzip -oq "$tmp/$t.zip" -d "$tmp" && mv "$tmp/$t" "$BIN/$t" && chmod +x "$BIN/$t"; xattr -d com.apple.quarantine "$BIN/$t" 2>/dev/null || true
    fi
  fi
  ok "$t em $BIN/$t"
done

echo "3. Node (para o MCP do Premiere)"
if ! command -v node >/dev/null || [ "$(node -p 'process.versions.node.split(".")[0]')" -lt 20 ]; then
  if command -v brew >/dev/null; then brew install node
  else warn "Precisa do Node 20+: instale em https://nodejs.org (LTS) e rode este script de novo"; exit 1; fi
fi
NODE=$(command -v node); ok "node $(node -v) em $NODE"

echo "4. Config do yt-dlp (H.264 + AAC em MP4, abre liso no Premiere)"
CFG="$HOME/.config/yt-dlp/config"
if [ ! -f "$CFG" ]; then
  mkdir -p "$(dirname "$CFG")"
  cat > "$CFG" <<EOF
# Runtime JS exigido pelo YouTube
--js-runtimes node:$NODE
# ffmpeg para juntar vídeo + áudio
--ffmpeg-location $BIN/ffmpeg
# Padrão: melhor H.264 + áudio AAC num MP4; cai pro melhor disponível se não houver
-f bv*[vcodec^=avc1]+ba[ext=m4a]/bv*+ba/b
--merge-output-format mp4
EOF
  ok "criado $CFG"
else ok "$CFG já existe (não mexi)"; fi

echo "5. MCP Bridge do Premiere (adobe-premiere-pro-mcp)"
npm install -g adobe-premiere-pro-mcp@latest >/dev/null
premiere-pro-mcp --install-cep || warn "--install-cep deu erro: veja a mensagem acima"
if command -v claude >/dev/null; then
  if claude mcp get premiere-pro >/dev/null 2>&1; then ok "MCP premiere-pro já registrado no Claude Code"
  else claude mcp add premiere-pro --scope user -e PREMIERE_MCP_TELEMETRY=0 -- premiere-pro-mcp && ok "MCP premiere-pro registrado no Claude Code"; fi
else warn "comando 'claude' não encontrado: registre o MCP depois com: claude mcp add premiere-pro --scope user -- premiere-pro-mcp"; fi
premiere-pro-mcp --doctor || true

cat <<'EOF'

Pronto. Falta só a parte manual:
  1. Feche e abra o Premiere Pro.
  2. Window › Extensions › MCP Bridge (CEP): confira a pasta da ponte e clique em Start Bridge.
  3. Instale a fonte Inter (fonts.google.com/specimen/Inter) se ainda não tiver.
  4. Abra uma sessão NOVA do Claude Code (MCP novo só carrega em sessão nova) e peça:
     "roda verify_premiere_connection, sem mudar nada".
EOF

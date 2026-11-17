#!/usr/bin/env bash
set -euo pipefail

REPO="ParkMu-Jin/nyx"
BASE="https://github.com/$REPO/releases/latest/download"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

if [ "${1:-}" = "--uninstall" ]; then
  rm -f "$BIN_DIR/nyx" "$APP_DIR/nyx.desktop" "$ICON_DIR/nyx.png"
  echo "NYX desinstalado."
  exit 0
fi

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Esta versión solo funciona en equipos x86_64." >&2
  exit 1
fi

descargar() {
  if command -v curl >/dev/null 2>&1; then
    curl -fL --progress-bar "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -q --show-progress "$1" -O "$2"
  else
    echo "Necesitas curl o wget." >&2
    exit 1
  fi
}

mkdir -p "$BIN_DIR" "$APP_DIR" "$ICON_DIR"

echo "Descargando NYX..."
TMP="$(mktemp)"
descargar "$BASE/NYX" "$TMP"
chmod +x "$TMP"
mv "$TMP" "$BIN_DIR/nyx"
descargar "$BASE/NYX.png" "$ICON_DIR/nyx.png" || true

cat > "$APP_DIR/nyx.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=NYX
Comment=NYX RRHH
Exec=$BIN_DIR/nyx
Icon=$ICON_DIR/nyx.png
Terminal=false
Categories=Office;
EOF

update-desktop-database "$APP_DIR" 2>/dev/null || true

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "Agrega $BIN_DIR a tu PATH para abrirlo con el comando: nyx" ;;
esac

echo "Listo. Ábrelo desde el menú de aplicaciones o escribiendo: nyx"
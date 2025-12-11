#!/usr/bin/env bash
set -euo pipefail

POSTMAN_TAR="${1:-}"

# If no tar.gz passed, download latest from Postman
if [[ -z "$POSTMAN_TAR" ]]; then
  echo "No .tar.gz specified. Downloading latest Postman for Linux (64-bit)..."
  TMP_DIR="$(mktemp -d)"
  cd "$TMP_DIR"
  curl -L "https://dl.pstmn.io/download/latest/linux64" -o postman.tar.gz
  POSTMAN_TAR="$TMP_DIR/postman.tar.gz"
  echo "Downloaded to: $POSTMAN_TAR"
fi

if [[ ! -f "$POSTMAN_TAR" ]]; then
  echo "Error: File '$POSTMAN_TAR' not found."
  exit 1
fi

echo "Using archive: $POSTMAN_TAR"

# Extract
tar -xzf "$POSTMAN_TAR"

if [[ ! -d "Postman" ]]; then
  echo "Error: 'Postman' directory not found after extraction."
  exit 1
fi

echo "Removing any existing /opt/Postman..."
sudo rm -rf /opt/Postman

echo "Moving Postman to /opt..."
sudo mv Postman /opt/

echo "Creating/Updating symlink /usr/local/bin/postman..."
sudo ln -sf /opt/Postman/Postman /usr/local/bin/postman

echo "Creating desktop entry at /usr/share/applications/postman.desktop..."
sudo tee /usr/share/applications/postman.desktop >/dev/null <<EOF
[Desktop Entry]
Name=Postman
GenericName=API Client
Comment=Postman API Platform
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/icons/icon_128x128.png
Terminal=false
Type=Application
Categories=Development;Utility;
EOF

echo "Updating desktop database (may show a warning on some systems)..."
sudo update-desktop-database || true

echo "Done! You can now:"
echo "  - Run Postman from the applications menu, or"
echo "  - Launch it from terminal with: postman &"

#!/bin/bash

set -euo pipefail

sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y ncurses-devel openssl-devel

echo "Installing asdf"
if [ ! -d "$HOME/.asdf" ]; then
    VERSION=$(curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | jq -r '.tag_name | ltrimstr("v")')
    curl -L "https://github.com/asdf-vm/asdf/releases/download/v${VERSION}/asdf-${VERSION}-linux-amd64.tar.gz" | tar xz
    mv asdf ~/.asdf
fi

# Symlink asdf to /usr/local/bin (VSCode extension won't work without)
sudo ln -sf "$HOME/.asdf/bin/asdf" /usr/local/bin/asdf

# Add shims to PATH in .bashrc if not already there
if ! grep -q '.asdf/shims' ~/.bashrc; then
    echo 'export PATH="$HOME/.asdf/shims:$PATH"' >> ~/.bashrc
fi

# Add shims to PATH for this script
export PATH="$HOME/.asdf/shims:$PATH"

if command -v erl &>/dev/null; then
    echo "Warning: Erlang already installed, skipping"
else
    echo "Installing Erlang"
    asdf plugin add erlang || true
    asdf install erlang latest
    asdf set -u erlang latest
fi

if command -v gleam &>/dev/null; then
    echo "Warning: Gleam already installed, skipping"
else
    echo "Installing Gleam"
    asdf plugin add gleam || true
    asdf install gleam latest
    asdf set -u gleam latest
fi

echo "Done!"
echo "Restart your shell or run: source ~/.bashrc"

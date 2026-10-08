#!/bin/bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
with_dev=false
case "${1:-}" in
  "") ;;
  --with-dev) with_dev=true ;;
  *) echo "Usage: bash scripts/install.sh [--with-dev]" >&2; exit 2 ;;
esac
[[ $# -le 1 ]] || { echo "Too many arguments" >&2; exit 2; }
[[ "$(uname -s)" == Darwin && "$(uname -m)" == arm64 ]] || {
  echo "Run in a native Apple Silicon macOS terminal (not Rosetta)." >&2; exit 1;
}
[[ -x /opt/homebrew/bin/brew ]] || {
  echo "Install Apple Silicon Homebrew first: https://brew.sh" >&2; exit 1;
}
eval "$(/opt/homebrew/bin/brew shellenv)"
xcode-select -p >/dev/null 2>&1 || {
  echo "Install Command Line Tools first: xcode-select --install" >&2; exit 1;
}
# Install software before changing shell configuration.
brew bundle --file="$repo_dir/Brewfile"
if $with_dev; then brew bundle --file="$repo_dir/Brewfile.dev"; fi

omz_revision=9112b53fa8b5ab556c7c893aa8be8a247ac512a0
if [[ ! -e "$HOME/.oh-my-zsh" ]]; then
  staging_dir="$(mktemp -d "${TMPDIR:-/tmp}/envsetup-omz.XXXXXX")"
  trap 'rm -rf "$staging_dir"' EXIT
  git clone https://github.com/ohmyzsh/ohmyzsh.git "$staging_dir/oh-my-zsh"
  git -C "$staging_dir/oh-my-zsh" checkout "$omz_revision"
  mv "$staging_dir/oh-my-zsh" "$HOME/.oh-my-zsh"
fi
[[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]] || {
  echo "Existing ~/.oh-my-zsh is incomplete; resolve it before retrying." >&2; exit 1;
}
# Preserve existing Oh My Zsh installations; never reset their local changes.
backup_dir="$(mktemp -d "$HOME/.envsetup-backup.XXXXXXXX")"
copy_config() {
  local source="$1" relative="$2" target="$HOME/$2"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$backup_dir/$(dirname "$relative")"
    cp -pP "$target" "$backup_dir/$relative"
  fi
  mkdir -p "$(dirname "$target")"
  # Remove a destination symlink so copying does not modify its old target.
  if [[ -L "$target" ]]; then rm "$target"; fi
  cp "$repo_dir/$source" "$target"
}
# Ghostty loads the macOS-specific path after XDG config.
copy_config config/ghostty/config.ghostty 'Library/Application Support/com.mitchellh.ghostty/config.ghostty'
copy_config config/starship/starship.toml .config/starship.toml
copy_config config/zsh/.zprofile .zprofile
copy_config config/zsh/.zshrc .zshrc
printf 'Configuration installed. Previous files: %s\n' "$backup_dir"
printf 'Open a new Ghostty window, then run: zsh "%s/scripts/verify.zsh"\n' "$repo_dir"

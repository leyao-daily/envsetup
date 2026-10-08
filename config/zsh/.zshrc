export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Starship owns the prompt.
plugins=(git)

# Add completions before Oh My Zsh runs compinit.
if command -v brew >/dev/null 2>&1; then
  _migration_brew_prefix="$(brew --prefix)"
  fpath=("$_migration_brew_prefix/share/zsh/site-functions" "$_migration_brew_prefix/share/zsh-completions" $fpath)
fi
source "$ZSH/oh-my-zsh.sh"

if [[ -n $_migration_brew_prefix ]]; then
  source "$_migration_brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
eval "$(starship init zsh)"
# Syntax highlighting loads after other widgets and prompt initialization.
if [[ -n $_migration_brew_prefix ]]; then
  source "$_migration_brew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
unset _migration_brew_prefix

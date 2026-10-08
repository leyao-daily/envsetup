#!/bin/zsh
# Run inside a freshly opened Ghostty session, with its normal startup files.
emulate -L zsh
setopt err_return
failures=0
check() {
  if eval "$2"; then print -r -- "OK   $1"; else
    print -r -- "FAIL $1"; (( failures += 1 ))
  fi
  return 0
}
# A child shell does not inherit functions/fpath; source startup in a contained process.
# Keep this script interactive so widget-based plugins initialize normally.
if [[ ! -o interactive ]]; then
  exec /bin/zsh -lic 'source "$1"' envsetup "$0"
fi
check 'Homebrew' '[[ $(command -v brew) == /opt/homebrew/bin/brew ]]'
check 'Starship executable' '(( $+commands[starship] ))'
check 'Starship prompt' '[[ $PROMPT == *starship* ]]'
check 'Oh My Zsh' '[[ -n $ZSH && -f $ZSH/oh-my-zsh.sh ]]'
check 'Extra completions' '[[ ${fpath[(Ie)/opt/homebrew/share/zsh-completions]} -gt 0 ]]'
check 'Autosuggestions' '(( $+functions[_zsh_autosuggest_start] ))'
check 'Syntax highlighting' '(( $+functions[_zsh_highlight] ))'
check 'Ghostty config' '[[ -f "$HOME/Library/Application Support/com.mitchellh.ghostty/config.ghostty" ]]'
check 'Starship config' '[[ -f ${STARSHIP_CONFIG:-$HOME/.config/starship.toml} ]]'
print -r -- "Failures: $failures"
(( failures == 0 ))

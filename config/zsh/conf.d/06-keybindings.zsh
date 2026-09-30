#!/bin/zsh
# Keybindings: vi mode on the prompt (zsh-vi-mode)
# Depends: 02-brew.zsh (for HOMEBREW_PREFIX), 05-editor.zsh (for EDITOR, used by `vv`)

# zsh-vi-mode (https://github.com/jeffreytse/zsh-vi-mode)
# Esc -> normal mode, motions/text objects/surround inline, `vv` -> edit line in $EDITOR.
# Init on source (not deferred) so bindkeys in later modules aren't overwritten.
# Manages KEYTIMEOUT itself (ZVM_KEYTIMEOUT / ZVM_ESCAPE_KEYTIMEOUT).
ZVM_INIT_MODE=sourcing
ZVM_CURSOR_STYLE_ENABLED=false               # same cursor in every mode; starship prompt symbol shows the mode
ZVM_SYSTEM_CLIPBOARD_ENABLED=true            # y/d/p go through the macOS clipboard
ZVM_CLIPBOARD_COPY_CMD=pbcopy
ZVM_CLIPBOARD_PASTE_CMD=pbpaste
ZVM_VI_HIGHLIGHT_BACKGROUND='#44475a'        # dracula selection
ZVM_VI_HIGHLIGHT_FOREGROUND='#f8f8f2'        # dracula foreground
ZVM_OPEN_CMD=open                            # gx opens URL/path under cursor
# ZVM_MODE_* constants only exist once the plugin is sourced, so set them from its config hook
zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT        # every new prompt starts in insert mode
}
_zvm_plugin="$HOMEBREW_PREFIX/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh"
[ -f "$_zvm_plugin" ] && source "$_zvm_plugin"
unset _zvm_plugin

# Autosuggest styling
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'

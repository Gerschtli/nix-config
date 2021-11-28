bindkey -v

autoload -Uz zkbd

[[ -z "$terminfo[kdch1]" ]] || bindkey -M vicmd "$terminfo[kdch1]" vi-delete-char
[[ -z "$terminfo[khome]" ]] || bindkey -M vicmd "$terminfo[khome]" vi-beginning-of-line
[[ -z "$terminfo[kend]" ]] || bindkey -M vicmd "$terminfo[kend]" vi-end-of-line
[[ -z "$terminfo[cuu1]" ]] || bindkey -M viins "$terminfo[cuu1]" vi-up-line-or-history
[[ -z "$terminfo[cuf1]" ]] || bindkey -M viins "$terminfo[cuf1]" vi-forward-char
[[ -z "$terminfo[kcuu1]" ]] || bindkey -M viins "$terminfo[kcuu1]" vi-up-line-or-history
[[ -z "$terminfo[kcud1]" ]] || bindkey -M viins "$terminfo[kcud1]" vi-down-line-or-history
[[ -z "$terminfo[kcuf1]" ]] || bindkey -M viins "$terminfo[kcuf1]" vi-forward-char
[[ -z "$terminfo[kcub1]" ]] || bindkey -M viins "$terminfo[kcub1]" vi-backward-char

# k Shift-tab Perform backwards menu completion
if [[ -n "$terminfo[kcbt]" ]]; then
    bindkey -M viins "$terminfo[kcbt]" reverse-menu-complete
elif [[ -n "$terminfo[cbt]" ]]; then
    bindkey -M viins "$terminfo[cbt]" reverse-menu-complete
fi

# ncurses stuff:
[[ "$terminfo[kcuu1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcuu1]/O/[}" vi-up-line-or-history
[[ "$terminfo[kcud1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcud1]/O/[}" vi-down-line-or-history
[[ "$terminfo[kcuf1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcuf1]/O/[}" vi-forward-char
[[ "$terminfo[kcub1]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kcub1]/O/[}" vi-backward-char
[[ "$terminfo[khome]" == $'\eO'* ]] && bindkey -M viins "${terminfo[khome]/O/[}" beginning-of-line
[[ "$terminfo[kend]" == $'\eO'* ]] && bindkey -M viins "${terminfo[kend]/O/[}" end-of-line

bindkey '\e[1~' beginning-of-line       # home
bindkey '\e[4~' end-of-line             # end
bindkey '\e[A' up-line-or-search        # cursor up
bindkey '\e[B' down-line-or-search      # <ESC>-

bindkey '^xp' history-beginning-search-backward
bindkey '^xP' history-beginning-search-forward

# beginning-of-line (^A) (unbound) (unbound)
# Move to the beginning of the line. If already at the beginning of the line,
# move to the beginning of the previous line, if any.
if [[ -n "${key[Home]}" ]]; then
    bindkey "${key[Home]}" beginning-of-line
    bindkey -M vicmd "${key[Home]}" vi-beginning-of-line
    bindkey -M viins "${key[Home]}" vi-beginning-of-line
fi

# end-of-line (^E) (unbound) (unbound)
# Move to the end of the line. If already at the end of the line, move to the
# end of the next line, if any.
if [[ -n "${key[End]}" ]]; then
    bindkey "${key[End]}" end-of-line
    bindkey -M vicmd "${key[End]}" vi-end-of-line
    bindkey -M viins "${key[End]}" vi-end-of-line
fi

# vi-delete-char (unbound) (x) (unbound)
# Delete the character under the cursor, without going past the end of the line.
if [[ -n "${key[Delete]}" ]]; then
    bindkey "${key[Delete]}" delete-char
    bindkey -M vicmd "${key[Delete]}" vi-delete-char
    bindkey -M viins "${key[Delete]}" vi-delete-char
fi

# backward-delete-char (^H ^?) (unbound) (unbound)
# Delete the character behind the cursor.
if [[ -n "${key[Backspace]}" ]]; then
    bindkey "${key[Backspace]}" backward-delete-char
    bindkey -M viins "${key[Backspace]}" backward-delete-char
    #bindkey -M vicmd "${key[Backspace]}" backward-delete-char
fi

# overwrite-mode (^X^O) (unbound) (unbound)
# Toggle between overwrite mode and insert mode.
if [[ -n "${key[Insert]}" ]]; then
    bindkey -M viins "${key[Insert]}" overwrite-mode
    bindkey -M emacs "${key[Insert]}" overwrite-mode
fi

# up-line-or-search
# Move up a line in the buffer, or if already at the top line, search backward
# in the history for a line beginning with the first word in the buffer.
[[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" up-line-or-search

# down-line-or-search
# Move down a line in the buffer, or if already at the bottom line, search
# forward in the history for a line beginning with the first word in the buffer.
[[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" down-line-or-search

# history-incremental-search-backward (^R ^Xr) (unbound) (unbound)
# Search backward incrementally for a specified string. The search is
# case-insensitive if the search string does not have uppercase letters and no
# numeric argument was given. The string may begin with "^" to anchor the search
# to the beginning of the line.
bindkey -M vicmd "\C-r" history-incremental-search-backward
bindkey -M viins "\C-r" history-incremental-search-backward

# history-incremental-search-forward (^S ^Xs) (unbound) (unbound)
# Search forward incrementally for a specified string. The search is
# case-insensitive if the search string does not have uppercase letters and no
# numeric argument was given. The string may begin with "^" to anchor the search
# to the beginning of the line. The functions available in the mini-buffer are
# the same as for history-incremental-search-backward.
bindkey -M vicmd "\C-s" history-incremental-search-forward
bindkey -M viins "\C-s" history-incremental-search-forward

# The zsh/complist Module
# The zsh/complist module offers three extensions to completion listings: the
# ability to highlight matches in such a list, the ability to scroll through
# long lists and a different style of menu completion.
autoload -Uz zsh/complist
zmodload -i zsh/complist

# accept-and-menu-complete
# In a menu completion, insert the current completion into the buffer, and
# advance to the next possible completion.
bindkey -M menuselect '\e^M' accept-and-menu-complete

bindkey '^ ' forward-word

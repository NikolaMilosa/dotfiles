edit_line_in_nvim() {
    tmpfile=$(mktemp)
    printf "%s" "$READLINE_LINE" > "$tmpfile"
    nvim "$tmpfile"
    
    READLINE_LINE=$(<"$tmpfile")
    READLINE_POINT=${#READLINE_LINE} 
    
    rm -f "$tmpfile"
}

bind -x '"\C-e": edit_line_in_nvim'

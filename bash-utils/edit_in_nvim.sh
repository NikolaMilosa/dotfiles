edit_line_in_nvim() {
    # Save current readline buffer into a temp file
    tmpfile=$(mktemp)
    # Get current command line
    printf "%s" "$READLINE_LINE" > "$tmpfile"
    
    # Open Neovim to edit it
    nvim "$tmpfile"
    
    # After editing, replace current line with new content
    READLINE_LINE=$(<"$tmpfile")
    READLINE_POINT=${#READLINE_LINE}   # move cursor to end
    
    # clean up
    rm -f "$tmpfile"
}

bind -x '"\C-e": edit_line_in_nvim'

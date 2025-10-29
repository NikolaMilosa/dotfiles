if command -v "bat" &>/dev/null; then
    #! alias -g -- h='-h 2>&1 | bat --language=help --style=plain --paging=never --color always' # <--- this is discouraged! This conflicts with posix -h test operator
    alias -g -- --help='--help 2>&1 | bat --language=help --style=plain --paging=never --color always'
    #alias cat='bat --style=plain --paging=never --color auto'
fi

better_cat() {
    if command -v "bat" &>/dev/null; then
        cat_cmd='bat --style=plain --paging=never --color auto'
    else
        cat_cmd='cat'
    fi

    if [ $# -eq 0 ]; then
        eval $cat_cmd
        return
    fi

    for file in "$@"; do
        if [ -f "$file" ]; then
            mime=$(file --mime-type -b "$file")
            if [[ "$mime" =~ ^image/ ]];  then
                if [ -n "$KITTY_WINDOW_ID" ]; then 
                    kitty +kitten icat "$file"       
                else
                    echo "Image detected ($mime) but currently not in kitty"
                    eval "$cat_cmd \"$file\""
                    return
                fi
            else
                eval "$cat_cmd \"$file\""
            fi
        else
            eval "$cat_cmd \"$file\""
        fi
    done
}

alias cat='better_cat'

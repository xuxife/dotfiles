if status is-interactive
    # starship
    starship init fish | source

    # fasd
    alias a='fasd -a'        # any
    alias s='fasd -si'       # show / search / select
    alias d='fasd -d'        # directory
    alias f='fasd -f'        # file
    alias sd='fasd -sid'     # interactive directory selection
    alias sf='fasd -sif'     # interactive file selection
    alias z='fasd_cd -d'     # cd, same functionality as j in autojump
    alias zz='fasd_cd -d -i' # cd with interactive selection
end

function replace_home_directory_in_fish_variables
    sed -i '' "s|$HOME|~|g" ~/.config/fish/fish_variables
end
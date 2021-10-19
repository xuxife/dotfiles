if status is-interactive
    # starship
    starship init fish | source

    # bind for stashing command
    bind \cs __commandline_toggle

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
    sed -i '' "s|$HOME|\x7e|g" ~/.config/fish/fish_variables
end

function __commandline_stash -d 'Stash current command line'
    set -g __stash_command_position (commandline -C)
    set -g __stash_command (commandline -b)
    commandline -r ""
end

function __commandline_pop -d 'Pop last stashed command line'
    if not set -q __stash_command
        return
    end
    commandline -r $__stash_command
    if set -q __stash_command_position
        commandline -C $__stash_command_position
    end
    set -e __stash_command
    set -e __stash_command_position
end

function __commandline_toggle -d 'Stash current commandline if not empty, otherwise pop last stashed commandline'
    set -l cmd (commandline -b)
    if test "$cmd"
        __commandline_stash
    else
        __commandline_pop
    end
end
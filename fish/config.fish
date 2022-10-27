if status is-interactive
    fish_vi_key_bindings

    # bind for stashing command
    bind \cs __commandline_toggle
    bind \cx\cc fzf-cd-widget
    bind \cg\cb fzf-git-branch-widget
    bind -M insert \cg\cb fzf-git-branch-widget

    set -gx FZF_DEFAULT_COMMAND "fd --strip-cwd-prefix"
    set -gx FZF_DEFAULT_OPTS "--height ~40% --multi --reverse --ansi \
        --bind ctrl-n:preview-half-page-down,ctrl-p:preview-half-page-up \
        --color=dark \
        --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f \
        --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7"
end

set -gx PATH ~/.local/bin $PATH
set -gx PATH ~/go/bin $PATH
set -gx PATH ~/.krew/bin $PATH
source ~/.local.config

starship init fish | source

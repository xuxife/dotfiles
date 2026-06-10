# aks-wt — cross-repo worktree helper for aks-devinfra
#
# Mirrors the `prepare-cross-repo-worktree` skill: creates an isolated
# workspace at <aks-devinfra-root>/.worktrees/<feature>/ with optional
# sibling worktrees for aks-rp / aks-e2e-infra.
#
# Subcommands:
#   aks-wt new <feature> [--branch B] [--rp] [--rp-from PATH]
#                                     [--e2e] [--e2e-from PATH]
#   aks-wt rm  <feature> [--force] [--keep-branch]
#   aks-wt ls
#   aks-wt help
#
# Env overrides:
#   AKS_DEVINFRA_ROOT     default: ~/repo/aks-devinfra
#   AKS_RP_PATH           default: ~/repo/aks-rp
#   AKS_E2E_INFRA_PATH    default: ~/repo/aks-e2e-infra
#   AKS_WT_BRANCH_PREFIX  default: xuxife    (branch = <prefix>/yy/mm/dd/<feature>)

function aks-wt --description "Cross-repo worktree helper for aks-devinfra"
    set -l sub $argv[1]
    set -l rest $argv[2..-1]

    switch "$sub"
        case new
            __aks_wt_new $rest
        case rm remove
            __aks_wt_rm $rest
        case ls list
            __aks_wt_ls $rest
        case help '' -h --help
            __aks_wt_help
        case '*'
            echo "aks-wt: unknown subcommand '$sub'" >&2
            __aks_wt_help >&2
            return 2
    end
end

function __aks_wt_help
    echo "Usage:"
    echo "  aks-wt new <feature> [--branch B] [--rp] [--rp-from PATH]"
    echo "                                    [--e2e] [--e2e-from PATH]"
    echo "  aks-wt rm  <feature> [--force] [--keep-branch]"
    echo "  aks-wt ls"
    echo ""
    echo "Defaults:"
    echo "  devinfra root : "(__aks_wt_devinfra_root)
    echo "  aks-rp path   : "(__aks_wt_rp_path)
    echo "  aks-e2e path  : "(__aks_wt_e2e_path)
    echo "  branch        : "(__aks_wt_branch_prefix)"/yy/mm/dd/<feature>"
end

function __aks_wt_devinfra_root
    if set -q AKS_DEVINFRA_ROOT
        echo $AKS_DEVINFRA_ROOT
    else
        echo $HOME/repo/aks-devinfra
    end
end

function __aks_wt_rp_path
    if set -q AKS_RP_PATH
        echo $AKS_RP_PATH
    else
        echo $HOME/repo/aks-rp
    end
end

function __aks_wt_e2e_path
    if set -q AKS_E2E_INFRA_PATH
        echo $AKS_E2E_INFRA_PATH
    else
        echo $HOME/repo/aks-e2e-infra
    end
end

function __aks_wt_branch_prefix
    if set -q AKS_WT_BRANCH_PREFIX
        echo $AKS_WT_BRANCH_PREFIX
    else
        echo xuxife
    end
end

function __aks_wt_default_branch --argument-names feature
    set -l prefix (__aks_wt_branch_prefix)
    set -l date (date +%y/%m/%d)
    echo "$prefix/$date/$feature"
end

# Add a sibling worktree from <src> at <wt-root>/<name> on branch <branch>.
# If <src> doesn't exist, prints a hint and returns non-zero (no auto-clone:
# the skill explicitly forbids auto-cloning without asking).
function __aks_wt_add_sibling --argument-names src wt_root name branch
    if not test -d $src/.git -o -f $src/.git
        echo "aks-wt: $name source repo not found at $src" >&2
        echo "        clone it first, or override with --$name-from PATH" >&2
        return 1
    end
    set -l dest $wt_root/$name
    echo "==> Adding $name worktree: $dest (branch $branch)"
    if git -C $src show-ref --verify --quiet refs/heads/$branch
        echo "    branch $branch already exists in $src — checking it out"
        git -C $src worktree add $dest $branch
    else
        git -C $src worktree add $dest -b $branch
    end
end

function __aks_wt_new
    set -l opts (fish_opt -s b -l branch -r)
    set -a opts (fish_opt -l rp)
    set -a opts (fish_opt -l rp-from -r)
    set -a opts (fish_opt -l e2e)
    set -a opts (fish_opt -l e2e-from -r)
    argparse $opts -- $argv
    or return 2

    if test (count $argv) -ne 1
        echo "aks-wt new: expected exactly one <feature> argument" >&2
        return 2
    end
    set -l feature $argv[1]

    # Validate feature looks like kebab-case (no slashes, no spaces).
    if string match -q -- '*/*' $feature; or string match -q -- '* *' $feature
        echo "aks-wt new: <feature> should be short kebab-case (got '$feature')" >&2
        return 2
    end

    set -l branch $_flag_branch
    if test -z "$branch"
        set branch (__aks_wt_default_branch $feature)
    end

    set -l root (__aks_wt_devinfra_root)
    if not test -d $root/.git
        echo "aks-wt: aks-devinfra root not a git repo: $root" >&2
        echo "        set AKS_DEVINFRA_ROOT to override" >&2
        return 1
    end

    set -l wt_root $root/.worktrees/$feature
    if test -e $wt_root
        echo "aks-wt: worktree dir already exists: $wt_root" >&2
        return 1
    end

    echo "==> Creating aks-devinfra worktree: $wt_root (branch $branch)"
    if git -C $root show-ref --verify --quiet refs/heads/$branch
        echo "    branch $branch already exists — checking it out"
        git -C $root worktree add $wt_root $branch
        or return $status
    else
        git -C $root worktree add $wt_root -b $branch
        or return $status
    end

    # Sub-repos. --*-from implies --*.
    set -l want_rp 0
    set -l rp_src (__aks_wt_rp_path)
    if set -q _flag_rp; set want_rp 1; end
    if set -q _flag_rp_from
        set want_rp 1
        set rp_src $_flag_rp_from
    end

    set -l want_e2e 0
    set -l e2e_src (__aks_wt_e2e_path)
    if set -q _flag_e2e; set want_e2e 1; end
    if set -q _flag_e2e_from
        set want_e2e 1
        set e2e_src $_flag_e2e_from
    end

    if test $want_rp -eq 1
        __aks_wt_add_sibling $rp_src $wt_root aks-rp $branch
        or return $status
    end
    if test $want_e2e -eq 1
        __aks_wt_add_sibling $e2e_src $wt_root aks-e2e-infra $branch
        or return $status
    end

    echo ""
    echo "Layout:"
    echo "  $wt_root/"
    echo "  ├── (aks-devinfra worktree files)"
    test $want_rp  -eq 1; and echo "  ├── aks-rp/         (branch $branch)"
    test $want_e2e -eq 1; and echo "  └── aks-e2e-infra/  (branch $branch)"
    echo ""
    cd $wt_root
end

# Resolve the source repo path for a linked worktree at <wt_path> by
# following its gitdir to the common .git directory.
function __aks_wt_source_repo --argument-names wt_path
    set -l common (git -C $wt_path rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    or return 1
    # Strip trailing /.git to get the source repo root.
    echo (string replace -r '/\.git/?$' '' $common)
end

function __aks_wt_rm
    set -l opts (fish_opt -l force)
    set -a opts (fish_opt -l keep-branch)
    argparse $opts -- $argv
    or return 2

    if test (count $argv) -ne 1
        echo "aks-wt rm: expected exactly one <feature> argument" >&2
        return 2
    end
    set -l feature $argv[1]
    set -l root (__aks_wt_devinfra_root)
    set -l wt_root $root/.worktrees/$feature

    if not test -d $wt_root
        echo "aks-wt rm: no worktree at $wt_root" >&2
        return 1
    end

    set -l force_flag
    if set -q _flag_force; set force_flag --force; end

    # Discover siblings: direct subdirectories of wt_root that are
    # themselves git worktrees (have a .git file/dir).
    set -l siblings
    for entry in $wt_root/*/
        set -l p (string trim -r -c / $entry)
        if test -e $p/.git
            set -a siblings $p
        end
    end

    # Safety check siblings first (unless --force). The devinfra wt is
    # checked AFTER siblings are removed, because sibling directories appear
    # as untracked entries (?? aks-rp/) in the devinfra wt and would
    # otherwise trip the dirty check.
    if not set -q _flag_force
        for p in $siblings
            set -l dirty (git -C $p status --porcelain)
            if test -n "$dirty"
                echo "aks-wt rm: uncommitted changes in $p" >&2
                echo "           commit/stash, or rerun with --force" >&2
                return 1
            end
            set -l unpushed (git -C $p log @{u}..HEAD --oneline 2>/dev/null)
            if test -n "$unpushed"
                echo "aks-wt rm: unpushed commits in $p" >&2
                echo "           push, or rerun with --force" >&2
                return 1
            end
        end
    end

    # Track branches to optionally delete after removal.
    set -l cleanup_pairs  # entries: "<src-repo>=<branch>"

    # Remove siblings first (they live inside wt_root).
    for p in $siblings
        set -l src (__aks_wt_source_repo $p)
        set -l br (git -C $p rev-parse --abbrev-ref HEAD)
        echo "==> Removing sibling worktree: $p (from $src)"
        git -C $src worktree remove $force_flag $p
        or return $status
        set -a cleanup_pairs "$src=$br"
    end

    # Now check the devinfra wt — siblings are gone, so untracked sibling
    # dirs no longer show up.
    if not set -q _flag_force
        set -l dirty (git -C $wt_root status --porcelain)
        if test -n "$dirty"
            echo "aks-wt rm: uncommitted changes in $wt_root" >&2
            echo "           commit/stash, or rerun with --force" >&2
            return 1
        end
        set -l unpushed (git -C $wt_root log @{u}..HEAD --oneline 2>/dev/null)
        if test -n "$unpushed"
            echo "aks-wt rm: unpushed commits in $wt_root" >&2
            echo "           push, or rerun with --force" >&2
            return 1
        end
    end

    # Then the aks-devinfra worktree.
    set -l devinfra_branch (git -C $wt_root rev-parse --abbrev-ref HEAD)
    echo "==> Removing aks-devinfra worktree: $wt_root"
    git -C $root worktree remove $force_flag $wt_root
    or return $status
    set -a cleanup_pairs "$root=$devinfra_branch"

    if not set -q _flag_keep_branch
        for pair in $cleanup_pairs
            set -l src (string split -m 1 = $pair)[1]
            set -l br (string split -m 1 = $pair)[2]
            echo "==> Deleting branch $br in $src"
            git -C $src branch -D $br
        end
    end
end

function __aks_wt_ls
    set -l root (__aks_wt_devinfra_root)
    set -l dir $root/.worktrees
    if not test -d $dir
        echo "(no worktrees at $dir)"
        return 0
    end
    for entry in $dir/*/
        set -l p (string trim -r -c / $entry)
        set -l feature (basename $p)
        set -l br (git -C $p rev-parse --abbrev-ref HEAD 2>/dev/null)
        echo "$feature  →  $br"
        for sub in $p/*/
            set -l sp (string trim -r -c / $sub)
            if test -e $sp/.git
                set -l sname (basename $sp)
                set -l sbr (git -C $sp rev-parse --abbrev-ref HEAD 2>/dev/null)
                echo "    └── $sname  →  $sbr"
            end
        end
    end
end

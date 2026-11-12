# Git for the dotfiles backup (bare repo in ~/.dotfiles, work tree = $HOME)
function dot --wraps git
    git --git-dir=$HOME/.dotfiles --work-tree=$HOME $argv
end

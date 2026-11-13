source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# recolor fastfetch (logo + keys) from end-4's theme primary color (colors.json) whenever the theme changes
# (kitty's ANSI slots are hue-locked, so they came out pink/red on many wallpapers)
set -l _th ~/.local/state/quickshell/user/generated/terminal/kitty-theme.conf
set -l _lg ~/.config/fastfetch/logo-themed.png
if test -f $_th; and begin; not test -f $_lg; or test $_th -nt $_lg; end
    set -l _acc (jq -r .primary ~/.local/state/quickshell/user/generated/colors.json)
    set -l _sh
    for L in 25 68 84 # dark, keys, light
        set -a _sh (magick xc:$_acc -colorspace HSL -channel G -fx 'max(u,0.5)' -channel B -evaluate set $L% +channel -colorspace sRGB -depth 8 txt:- | string match -r '#\w{6}')
    end
    magick ~/.config/fastfetch/logo.png -background none \( +clone -alpha off -colorspace gray -level 35%,85% -colorspace sRGB +level-colors "$_sh[1]","$_sh[3]" \) +swap -compose CopyOpacity -composite $_lg
    set -l _rgb (string join ';' (math 0x(string sub -s 2 -l 2 $_sh[2])) (math 0x(string sub -s 4 -l 2 $_sh[2])) (math 0x(string sub -s 6 -l 2 $_sh[2])))
    set -l _rgb2 (string join ';' (math 0x(string sub -s 2 -l 2 $_sh[3])) (math 0x(string sub -s 4 -l 2 $_sh[3])) (math 0x(string sub -s 6 -l 2 $_sh[3])))
    awk -v a=$_sh[2] -v b=$_sh[3] -v ra=$_rgb -v rb=$_rgb2 '/"keyColor":/ { n++; sub(/"keyColor": *"[^"]*"/, "\"keyColor\": \"" (n%2 ? a : b) "\"") }
        /"format": "\{#1\}/ { sub(/"format": .*/, "\"format\": \"{#1}{#38;2;" ra "}{user-name}{#0}{#90} @ {#1}{#38;2;" rb "}{host-name}\"") } { print }' ~/.config/fastfetch/config.jsonc > ~/.config/fastfetch/config.jsonc.tmp; and mv ~/.config/fastfetch/config.jsonc.tmp ~/.config/fastfetch/config.jsonc
end

fish_add_path $HOME/TNFXFetch/venv/bin
starship init fish | source

alias ls='eza --icons'
alias ll='eza -lah --icons --git'
alias tree='eza --tree --icons'
zoxide init fish | source

# Nord terminal aliases
alias ls="eza --icons"
alias ll="eza -lah --icons --git"
alias tree="eza --tree --icons"

fish_add_path /home/efeserdaroglu/.spicetify

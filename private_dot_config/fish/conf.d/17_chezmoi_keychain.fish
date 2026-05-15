# Wrap chezmoi so commands that render templates pull the KeePassXC database
# master password from the macOS Keychain instead of prompting interactively.
# The Keychain entry is unlocked by Touch ID on first read per login session,
# so subsequent `chezmoi apply`/`chezmoi diff` runs are silent.
#
# One-time setup on a new Mac:
#   security add-generic-password \
#       -a $USER -s chezmoi-keepassxc -w 'YOUR-KDBX-MASTER-PASSWORD' -U
#
# To remove the cached password:
#   security delete-generic-password -a $USER -s chezmoi-keepassxc

function chezmoi --wraps=chezmoi
    # Only the subcommands below evaluate templates and therefore need the
    # database password. Anything else (edit, cd, git, init, ...) is passed
    # through untouched so it keeps its TTY.
    set -l needs_secret 0
    switch "$argv[1]"
        case apply diff verify status dump execute-template generate
            set needs_secret 1
    end

    if test $needs_secret -eq 1
        set -l pw (security find-generic-password -a $USER -s chezmoi-keepassxc -w 2>/dev/null)
        if test -n "$pw"
            echo "$pw" | command chezmoi --no-tty $argv
            return $status
        end
    end

    command chezmoi $argv
end

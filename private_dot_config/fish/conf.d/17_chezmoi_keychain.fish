# Wrap chezmoi so commands that render templates pull the KeePassXC database
# master password from the macOS Keychain instead of prompting interactively.
# The Keychain entry is unlocked by Touch ID on first read per login session,
# so subsequent `chezmoi apply`/`chezmoi diff` runs are silent.
#
# Two execution paths for template-rendering subcommands:
#   - Interactive TTY: spawn chezmoi under expect(1), auto-answer the kdbx
#     password prompt, then hand the PTY back to the user so any further
#     chezmoi prompts (overwrite/all-overwrite/skip/quit on local divergence,
#     merges, etc.) behave normally.
#   - Non-interactive (scripts/CI): feed the password via stdin with --no-tty.
#     Note: in this path, if chezmoi raises any follow-up prompt it will EOF
#     and abort — reconcile the path manually or pass --force.
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

    if test $needs_secret -eq 0
        command chezmoi $argv
        return $status
    end

    set -l pw (security find-generic-password -a $USER -s chezmoi-keepassxc -w 2>/dev/null)
    if test -z "$pw"
        command chezmoi $argv
        return $status
    end

    if not isatty stdin; or not isatty stdout
        echo "$pw" | command chezmoi --no-tty $argv
        return $status
    end

    # Interactive path: spawn chezmoi under expect, auto-answer the kdbx
    # password prompt, then `interact` hands the PTY back to the user.
    set -lx CHEZMOI_KDBX_PW $pw
    set -lx CHEZMOI_ARGC (count $argv)
    for i in (seq $CHEZMOI_ARGC)
        set -lx CHEZMOI_ARGV_$i $argv[$i]
    end
    expect -c '
        set timeout -1
        set pw $env(CHEZMOI_KDBX_PW)
        set argc $env(CHEZMOI_ARGC)
        set chezmoi_args [list]
        for {set i 1} {$i <= $argc} {incr i} {
            lappend chezmoi_args $env(CHEZMOI_ARGV_$i)
        }
        spawn -noecho chezmoi {*}$chezmoi_args
        expect {
            -re {Enter password[^\r\n]*: ?} {
                send -- "$pw\r"
            }
            eof {
                catch wait result
                exit [lindex $result 3]
            }
        }
        interact
        catch wait result
        exit [lindex $result 3]
    '
end

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$BASHRC_DIR/bashrc.d" ]; then
    for bashrc_file in "$BASHRC_DIR"/bashrc.d/*.bash; do
        [ -r "$bashrc_file" ] && . "$bashrc_file"
    done
fi
unset BASHRC_DIR bashrc_file

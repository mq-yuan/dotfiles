# ~/.config/fish/modules/tools_update/functions/__tools_update_get_list.fish

# This function is the Single Source of Truth for the tool list.
# It provides the configuration to both the main function and the completion script.
function __tools_update_get_list
    # Format: Name, Check Command, Update Command, Type, Sudo Required?
    set -l tools \
        "Homebrew"         "brew"                 "brew update && brew upgrade"                    "user"     "no"  \
        "APT"              "apt"                  "sudo apt update && sudo apt upgrade"            "system"   "yes" \
        "Flatpak"          "flatpak"              "flatpak update -y"                              "user"     "no"  \
        "ASDF_Plugin"             "asdf"                 "asdf plugin update --all"                       "language" "no"  \
        "Fisher_Plugin"           "fisher"               "fisher update"                                  "fish"     "no"  \
        "Snap"             "snap"                 "sudo snap refresh"                              "system"   "yes" \
        "Cargo_Binaries"   "cargo-install-update" "cargo install-update --all"                     "language" "no"  \
        "Rustup"           "rustup"               "rustup update"                                  "language" "no"  \
        "UV_Tools"         "uv"                   "uv tool upgrade --all"                          "language" "no"

    # Output the entire list, one element per line.
    for item in $tools
        echo "$item"
    end
end

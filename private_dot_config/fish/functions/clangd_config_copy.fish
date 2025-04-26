# ~/.config/fish/functions/clangd_config_copy.fish
function clangd_config_copy --description 'Copies .clangd and .clang-format from $HOME/.config/clangd to the current working directory.'
  # Define the source directory where the .clangd and .clang-format files are stored.
  set -l source_dir $HOME/.config/clangd

  # Define the destination directory (current working directory).
  set -l dest_dir .

  # Check if the source directory exists.  If not, exit with an error.
  if not test -d $source_dir
    echo "Error: Source directory '$source_dir' does not exist."
    return 1
  end

  # Check if .clangd exists in source directory.
  if test -e $source_dir/.clangd
    # Copy .clangd to the current directory.  Use `-n` to prevent overwriting if it already exists.
    cp -n $source_dir/.clangd $dest_dir
    if test $status -eq 0
      echo ".clangd copied to current directory."
    else
      echo ".clangd already exists in current directory."
    end
  else
    echo ".clangd not found in $source_dir"
  end
  
  # Check if .clang-format exists in source directory.
  if test -e $source_dir/.clang-format
    # Copy .clang-format to the current directory.  Use `-n` to prevent overwriting if it already exists.
    cp -n $source_dir/.clang-format $dest_dir
    if test $status -eq 0
        echo ".clang-format copied to current directory."
    else
        echo ".clang-format already exists in current directory."
    end
  else
    echo ".clang-format not found in $source_dir"
  end

  # Indicate success.
  return 0
end

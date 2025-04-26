# ~/.config/fish/functions/scripts_python.fish
function scripts_python -d "Run Python scripts with uv"
    set script_name $argv[1]
    set script_args $argv[2..-1]
    set python_path "$SCRIPTS_HOME/.venv/bin/python"
    if not test -f "$SCRIPTS_HOME/$script_name.py"
        echo "Error: Script $script_name.py not found in $SCRIPTS_HOME/"
        return 1
    end
    if not test -f "$python_path"
        echo "Error: Python interpreter not found at $python_path"
        return 1
    end
    uv run --no-project --python="$python_path" "$SCRIPTS_HOME/$script_name.py" $script_args
end

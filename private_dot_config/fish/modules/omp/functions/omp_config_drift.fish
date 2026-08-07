# ~/.config/fish/modules/omp/functions/omp_config_drift.fish

# Semantic drift check for the omp agent config.
#
# omp rewrites ~/.config/omp/agent/config.yml on every TUI settings change,
# stripping comments, quotes, and key order, so a plain `chezmoi diff` is
# mostly formatting noise. This function normalizes both sides to canonical
# JSON and reports only real value differences.
#
# Exit status: 0 = in sync, 1 = drift detected (or error).
function omp_config_drift --description "Show semantic diff between live and chezmoi-managed omp agent config"
    set -l target ~/.config/omp/agent/config.yml
    set -l source (chezmoi source-path $target)
    or return 1

    set -l py_script '
import difflib
import json
import sys

import yaml

target_path, source_path = sys.argv[1], sys.argv[2]

with open(target_path) as f:
    live = yaml.safe_load(f)
with open(source_path) as f:
    managed = yaml.safe_load(f)

a = json.dumps(live, sort_keys=True, indent=1).splitlines()
b = json.dumps(managed, sort_keys=True, indent=1).splitlines()
diff = list(difflib.unified_diff(a, b, "live", "chezmoi-source", lineterm=""))
if not diff:
    print("omp agent config: in sync (no semantic drift)")
    sys.exit(0)
print("\n".join(diff))
print()
print("Reconcile: port the live values into the annotated chezmoi source,")
print("then run: chezmoi apply --force ~/.config/omp/agent/config.yml")
sys.exit(1)
'

    printf '%s\n' $py_script | uv run --quiet --with pyyaml python - $target $source
end

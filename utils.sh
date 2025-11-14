#!/bin/bash
set -e

function print_header(){
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    echo $1
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

# Disable all tensorflow warnings/info (keep errors)
export TF_CPP_MIN_LOG_LEVEL=2

# Directory of this script
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR=${THIS_DIR}

# Activate venv if present; otherwise continue with system Python
if [ -f "$BASE_DIR/venv/bin/activate" ]; then
    source "$BASE_DIR/venv/bin/activate"
    echo "Entered virtualenv."
    # Determine site-packages dynamically to avoid hardcoded paths
    PY_SITE=$(python - <<'PY'
import sys
try:
    import site
    paths = getattr(site, 'getsitepackages', lambda: [])()
except Exception:
    paths = []
try:
    import sysconfig
    paths.append(sysconfig.get_paths().get('purelib'))
except Exception:
    pass
print([p for p in paths if p][0])
PY
)
    export PYTHONPATH="$PY_SITE"
else
    echo "No venv found; using system Python."
fi

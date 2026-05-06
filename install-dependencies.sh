#!/usr/bin/env bash
# Install Python dependencies for this agent.
# Resilient to fresh hosts that don't have `pip` on PATH:
#   - Debian/Ubuntu out of the box has python3 but not pip — falls through to `python3 -m pip`.
#   - macOS often only has `pip3`.
#   - PEP 668 systems (newer Ubuntu/Debian) need --break-system-packages on `python3 -m pip`.
set -euo pipefail

if command -v pip >/dev/null 2>&1; then
    pip install -r requirements.txt
elif command -v pip3 >/dev/null 2>&1; then
    pip3 install -r requirements.txt
elif command -v python3 >/dev/null 2>&1; then
    python3 -m pip install -r requirements.txt --break-system-packages 2>/dev/null \
        || python3 -m pip install -r requirements.txt
else
    echo "ERROR: no pip / pip3 / python3 found on PATH — install Python 3.x first" >&2
    exit 1
fi

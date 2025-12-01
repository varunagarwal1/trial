#!/usr/bin/env bash
set -e

echo ">>> Ensure sed is available"
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y --no-install-recommends sed
else
  echo "apt-get not available; will try vendoring busybox next"
fi

echo ">>> build.sh: creating venv and installing Python dependencies"

# create the venv
python3 -m venv .venv

# activate venv
. .venv/bin/activate

# upgrade pip and tools, then install requirements
echo ">>> Upgrading pip, setuptools, wheel"
python -m pip install --upgrade pip setuptools wheel

echo ">>> Installing requirements from requirements.txt"
python -m pip install -r requirements.txt --no-cache-dir

# show which python was used and where site-packages live
echo ">>> venv information"
echo "VENV python: $(which python)"
python -V
python -c "import sysconfig; print('SITE_PACKAGES=' + sysconfig.get_path('purelib'))"

echo ">>> build.sh: finished"

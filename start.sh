#!/usr/bin/env bash
set -e
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

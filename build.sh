#!/usr/bin/env bash
set -e

# create a venv in the project folder
python3 -m venv .venv

# activate it
. .venv/bin/activate

# upgrade pip first (optional but recommended)
python -m pip install --upgrade pip setuptools wheel

# install requirements into the venv
python -m pip install -r requirements.txt --no-cache-dir

# Optional: create an "installed libs" dir to be used by the runtime if needed
# (not necessary if you start Odoo using the .venv python)

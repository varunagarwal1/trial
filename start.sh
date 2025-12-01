#!/usr/bin/env bash
set -e

# Activate the venv created at build time
. .venv/bin/activate

echo "Using Python from: $(which python)"
python --version
pip list

# Start Odoo using the venv python
exec python /opt/odoo/odoo-bin -c /etc/odoo/odoo.conf

#!/usr/bin/env bash
set -euo pipefail

echo ">>> start.sh: ensuring sed is available via apt or BusyBox vendor"

mkdir -p .local/bin

# Try to install sed via apt-get if available (build time)
if command -v apt-get >/dev/null 2>&1; then
  echo ">>> apt-get found: attempting to install sed"
  apt-get update -y
  apt-get install -y --no-install-recommends sed || true
fi

# If sed still not present, vendor BusyBox into .local/bin
if ! command -v sed >/dev/null 2>&1; then
  echo ">>> sed not found. Will try to download BusyBox into .local/bin"
  # detect architecture
  ARCH="$(uname -m || true)"
  echo ">>> detected architecture: $ARCH"

  # choose candidate URLs (x86_64 preferred). Adjust if your platform differs.
  BUSYBOX_CANDIDATES=(
    "https://busybox.net/downloads/binaries/1.31.1-x86_64/busybox"
    "https://busybox.net/downloads/binaries/1.31.1-i386/busybox"
    "https://busybox.net/downloads/binaries/1.21.1/busybox" # fallback
  )

  DEST=".local/bin/busybox"
  DL_OK=0
  for url in "${BUSYBOX_CANDIDATES[@]}"; do
    echo ">>> trying $url ..."
    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "$url" -o "$DEST" && DL_OK=1 && break || echo "curl failed for $url"
    elif command -v wget >/dev/null 2>&1; then
      wget -qO "$DEST" "$url" && DL_OK=1 && break || echo "wget failed for $url"
    else
      echo ">>> neither curl nor wget available to download BusyBox; aborting vendor download"
      break
    fi
  done

  if [ "$DL_OK" -ne 1 ]; then
    echo ">>> Failed to download BusyBox. Please ensure the builder allows outbound downloads or enable apt-get."
    # exit non-zero so build fails loudly (you can change to non-fatal if desired)
    exit 1
  fi

  chmod +x "$DEST"
  ln -sf busybox .local/bin/sed
  echo ">>> BusyBox downloaded to $DEST and sed shim created at .local/bin/sed"
fi

# Ensure local bin is prepended to PATH for subsequent steps
export PATH="$PWD/.local/bin:$PWD/.venv/bin:$PATH"
echo ">>> PATH now: $PATH"

# Verify sed exists now
if command -v sed >/dev/null 2>&1; then
  echo ">>> sed detected at: $(command -v sed)"
else
  echo ">>> sed still not found — build will fail. Exiting."
  exit 1
fi

# Continue with venv creation and pip install (same as before)
echo ">>> start.sh: creating venv and installing Python dependencies"

python3 -m venv .venv
. .venv/bin/activate

echo ">>> Upgrading pip, setuptools, wheel"
python -m pip install --upgrade pip setuptools wheel

echo ">>> Installing requirements from requirements.txt"
python -m pip install -r requirements.txt --no-cache-dir

# show which python was used and where site-packages live
echo ">>> venv information"
echo "VENV python: $(which python)"
python -V
python -c "import sysconfig; print('SITE_PACKAGES=' + sysconfig.get_path('purelib'))"

echo ">>> start.sh: finished"

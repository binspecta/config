#!/bin/bash
set -euo pipefail

# --- Node.js 20 ------------------------------------------------------------
# Download the setup script first, then run it, instead of piping a network
# stream straight into a root shell.
nodesetup="$(mktemp)"
curl -fsSL https://deb.nodesource.com/setup_20.x -o "$nodesetup"
sudo -E bash "$nodesetup"
rm -f "$nodesetup"
sudo apt install -y nodejs

sudo npm i -g rivalz-node-cli

df -h

# --- rivalz prover binary --------------------------------------------------
# rivalzPPH is fetched from a third-party Google Drive link whose contents can
# be changed at any time by whoever controls the file. Pin its SHA-256 so a
# swapped or tampered binary is rejected before it ever runs.
#
# First run prints the hash and stops. Verify the source, then re-run with:
#   export RIVALZPPH_SHA256=<printed hash>
RIVALZPPH_URL='https://drive.google.com/uc?export=download&id=1GHhIZ_7nVc6G030Tz6NRWCyQ4rGyWPRp'
REFERRAL_ID="${RIVALZ_REFERRAL_ID:-683271736128438286}"

curl -sSL -o rivalzPPH "$RIVALZPPH_URL"

# Make sure we actually got a binary, not an HTML interstitial page (Google
# Drive serves one for some downloads).
if command -v file >/dev/null 2>&1; then
    if ! file rivalzPPH | grep -qiE 'ELF|executable'; then
        echo "Downloaded rivalzPPH is not an executable (got: $(file -b rivalzPPH))." >&2
        echo "The Google Drive link may be returning an HTML page. Aborting." >&2
        rm -f rivalzPPH
        exit 1
    fi
fi

actual_sha="$(sha256sum rivalzPPH | awk '{print $1}')"
echo "rivalzPPH SHA-256: $actual_sha"

if [ -z "${RIVALZPPH_SHA256:-}" ]; then
    {
        echo
        echo "RIVALZPPH_SHA256 is not set, so this binary is UNVERIFIED."
        echo "Inspect the hash above against a trusted source, then re-run with:"
        echo "  export RIVALZPPH_SHA256=$actual_sha"
        echo "Refusing to auto-execute an unverified binary. Aborting."
    } >&2
    exit 1
fi

if [ "$actual_sha" != "$RIVALZPPH_SHA256" ]; then
    echo "SHA-256 mismatch! expected $RIVALZPPH_SHA256 but got $actual_sha." >&2
    echo "Refusing to run a binary that does not match the pinned hash." >&2
    rm -f rivalzPPH
    exit 1
fi
echo "SHA-256 matches the pinned value. Proceeding."

chmod +x rivalzPPH
echo "$REFERRAL_ID" | ./rivalzPPH

rivalz change-hardware-config

rivalz run

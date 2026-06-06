#!/bin/bash
set -euo pipefail

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


mkdir -p ~/pingpong

wget https://pingpong-build.s3.ap-southeast-1.amazonaws.com/linux/latest/PINGPONG -O ~/pingpong/PINGPONG

# Report (and optionally verify) the binary's hash before it is ever run.
# Pin it by exporting PINGPONG_SHA256=<hash> to have a mismatch rejected.
actual_sha="$(sha256sum ~/pingpong/PINGPONG | awk '{print $1}')"
echo "PINGPONG SHA-256: $actual_sha"
if [ -n "${PINGPONG_SHA256:-}" ] && [ "$actual_sha" != "$PINGPONG_SHA256" ]; then
    echo "SHA-256 mismatch! expected $PINGPONG_SHA256 but got $actual_sha." >&2
    echo "Refusing to keep a binary that does not match the pinned hash." >&2
    rm -f ~/pingpong/PINGPONG
    exit 1
fi

chmod +x ~/pingpong/PINGPONG

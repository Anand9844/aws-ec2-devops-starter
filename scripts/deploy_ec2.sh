#!/usr/bin/env bash
set -euo pipefail

# Run this script ON the Ubuntu EC2 instance after cloning your own GitHub repo.
# Example: bash scripts/deploy_ec2.sh
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is missing. Install Docker Engine first; see README.md."
  exit 1
fi

docker compose version >/dev/null
docker compose up -d --build
echo "Deployment started. Check: curl -i http://localhost/health"
docker compose ps

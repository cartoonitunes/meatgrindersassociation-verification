#!/bin/bash
# Reproducible verification — installs solc wrapper + soljson, then runs verify.js.
set -e
cd "$(dirname "$0")"

if [ ! -f soljson-v0.2.1.js ]; then
  echo "Downloading soljson-v0.2.1+commit.91a6b35f..."
  curl -sSLO https://binaries.soliditylang.org/bin/soljson-v0.2.1+commit.91a6b35f.js
  mv soljson-v0.2.1+commit.91a6b35f.js soljson-v0.2.1.js
fi

if [ ! -d node_modules/solc ]; then
  echo "Installing solc@0.4.26 wrapper..."
  npm install --no-save --no-audit --no-fund --silent solc@0.4.26
fi

node verify.js

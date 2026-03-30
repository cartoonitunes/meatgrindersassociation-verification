#!/bin/bash
set -e

CONTRACT="0xc7e9ddd5358e08417b1c88ed6f1a73149beeaa32"
# On-chain runtime bytecode (4,640 bytes)
EXPECTED=$(cat onchain-runtime.hex)

echo "Contract: $CONTRACT"
echo "Compiler: soljson-v0.2.1+commit.91a6b35f (optimizer ON)"
echo ""

# Check if soljson is available
SOLJSON="soljson-v0.2.1+commit.91a6b35f.js"
if [ ! -f "$SOLJSON" ]; then
    echo "Downloading soljson v0.2.1..."
    curl -sO "https://binaries.soliditylang.org/bin/$SOLJSON"
fi

# Compile with node + soljson
if command -v node &>/dev/null; then
    COMPILED=$(node -e "
const solc = require('./$SOLJSON');
const fs = require('fs');
const src = fs.readFileSync('MeatGrindersAssociation.sol', 'utf8');
const output = solc.compile(src, 1);
const contract = output.contracts['MeatGrindersAssociation'];
process.stdout.write(contract.runtimeBytecode);
" 2>/dev/null)
    
    echo "Compiled runtime bytecode: $((${#COMPILED} / 2)) bytes"
    echo "On-chain runtime bytecode: $((${#EXPECTED} / 2)) bytes"
    echo ""
    
    if [ "${COMPILED,,}" = "${EXPECTED,,}" ]; then
        echo "EXACT MATCH - byte-for-byte identical ($((${#COMPILED} / 2)) bytes)"
        echo ""
        echo "Contract:  $CONTRACT"
        echo "Block:     1,211,176 (March 24-25, 2016)"
        echo "Deployer:  0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb (avsa / Alex Van de Sande)"
        echo "Source:    MeatGrindersAssociation.sol"
        echo "Compiler:  soljson-v0.2.1+commit.91a6b35f"
        echo "Settings:  optimizer on"
        exit 0
    else
        echo "NO MATCH"
        exit 1
    fi
else
    echo "Node.js not found. Please install node to run verification."
    exit 1
fi

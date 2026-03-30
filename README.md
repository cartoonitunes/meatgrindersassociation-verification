# MeatGrindersAssociation Contract Verification

**Byte-for-byte verified** runtime bytecode for the MeatGrindersAssociation (Unicorn Meat Grinder) contract deployed on Ethereum mainnet.

## Contract

- **Address**: [`0xc7e9ddd5358e08417b1c88ed6f1a73149beeaa32`](https://etherscan.io/address/0xc7e9ddd5358e08417b1c88ed6f1a73149beeaa32)
- **Deployed**: March 24-25, 2016 (block 1,211,176)
- **Deployer**: `0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb` (avsa / Alex Van de Sande)
- **Etherscan name**: "Unicorn Meat Grinder Association"
- **Runtime bytecode**: 4,640 bytes

## Compiler

- **Version**: `soljson-v0.2.1+commit.91a6b35f.js` (emscripten/JS build)
- **Optimizer**: ON
- **Available at**: https://binaries.soliditylang.org/bin/soljson-v0.2.1+commit.91a6b35f.js

## Key Finding

The publicly known source code for this contract (published by avsa on GitHub gist) uses `contract MeatGrindersAssociation is owned`, inheriting from a separate `owned` base contract. However, the actual deployed bytecode was compiled **without inheritance** — `owner`, `onlyOwner`, and `transferOwnership` are all defined inline within `MeatGrindersAssociation` itself.

Additional structural differences from the published source:
- `transferOwnership` appears between `vote` and `executeProposal` (not at the top with other owner functions)
- `receiveApproval` appears before `sqrt`
- The constructor explicitly sets `owner = msg.sender` inline rather than via a base class

This corrected source file (`MeatGrindersAssociation.sol`) produces an exact byte-for-byte runtime bytecode match.

## Verification

```bash
# Download soljson v0.2.1
curl -O https://binaries.soliditylang.org/bin/soljson-v0.2.1+commit.91a6b35f.js

# Run verification script
chmod +x verify.sh
./verify.sh
```

Or manually:

```bash
node -e "
const solc = require('./soljson-v0.2.1+commit.91a6b35f.js');
const fs = require('fs');
const src = fs.readFileSync('MeatGrindersAssociation.sol', 'utf8');
const output = solc.compile(src, 1);
console.log(output.contracts['MeatGrindersAssociation'].runtimeBytecode);
"
```

Compare the output against `onchain-runtime.hex`.

## Historical Context

The Unicorn Meat Grinder Association was deployed in March 2016 by Alex Van de Sande, a core Ethereum Foundation developer. It governed the transformation ("grinding") of the original Ethereum Foundation Unicorn tokens into a new Unicorn Meat token. The contract used quadratic voting weighted by token ownership and bribe amounts. It was part of the Ethereum April Fool's Day 2016 announcement.

## Links

- [EthereumHistory.com](https://www.ethereumhistory.com/contract/0xc7e9ddd5358e08417b1c88ed6f1a73149beeaa32)
- [awesome-ethereum-proofs](https://github.com/cartoonitunes/awesome-ethereum-proofs)
- [Sourcify](https://repo.sourcify.dev/contracts/full_match/1/0xc7e9ddd5358e08417b1c88ed6f1a73149beeaa32/)
- [Original gist (with inheritance — does NOT match deployed bytecode)](https://gist.github.com/alexvandesande/3abc9f741471e08a6356)

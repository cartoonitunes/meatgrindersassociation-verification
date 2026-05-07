# MeatGrindersAssociation Verification

Byte-for-byte bytecode verification for `0xc7e9dDd5358e08417b1C88ed6f1a73149BEeaa32`.

| Field | Value |
|---|---|
| Contract | [`0xc7e9dDd5358e08417b1C88ed6f1a73149BEeaa32`](https://etherscan.io/address/0xc7e9dDd5358e08417b1C88ed6f1a73149BEeaa32) |
| Network | Ethereum Mainnet |
| Block | 1,211,176 |
| Deployed | 2016-03-24 22:55:56 UTC |
| Deployer | [`0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb`](https://etherscan.io/address/0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb) |
| Deploy tx | [`0xe9653360212cb38996a13def35272cb05b3e06f4344c1673514973c92367f054`](https://etherscan.io/tx/0xe9653360212cb38996a13def35272cb05b3e06f4344c1673514973c92367f054) |
| Compiler | soljson v0.2.1+commit.91a6b35f |
| Optimizer | ON |
| Runtime match | ✅ EXACT (4640 bytes) |
| Creation match | ✅ EXACT (5040 bytes deploy + 192 bytes constructor args) |

## Verification

```bash
./verify.sh
```

The script downloads `soljson-v0.2.1+commit.91a6b35f.js`, installs the
`solc@0.4.26` wrapper, recompiles `MeatGrindersAssociation.sol` with the
optimizer ON, and compares the resulting runtime + creation bytecode against
the on-chain copies in `onchain-runtime.hex` / `onchain-creation.hex`.

## Constructor arguments

| # | Name | Value |
|---|---|---|
| 0 | `unicornAddress` | `0x89205a3a3b2a69de6dbf7f01ed13b2108b2c43e7` (Unicorn token) |
| 1 | `meatAddress` | `0xed6ac8de7c7ca7e3a22952e09c2a2a1232ddef9a` (Unicorn Meat token) |
| 2 | `minimumUnicornsToPassAVote` | `1` |
| 3 | `minutesForDebate` | `0` |
| 4 | `multiplierForVotesAgainst` | `4` |
| 5 | `meatCalculator` | `0x4ab274fc3a81b300a0016b3805d9b94c81fa54d2` (MeatConversionCalculator) |

## What this contract does

`MeatGrindersAssociation` is a small token-weighted DAO from a 2016 Ethereum
demo by Alex Van de Sande. Holders of the Unicorn token (the "shareholders")
can submit proposals, vote on them with weight = balance × `sqrt(msg.value +
msg.gas * tx.gasprice)` (a quadratic-bribe weighting), and execute approved
proposals by forwarding ether + arbitrary calldata to the proposal's
recipient.

It also exposes a `grindUnicorns(amount)` flow that pulls Unicorn tokens from
the caller and mints Unicorn Meat tokens in proportion to the amount, using
an external `MeatCalculator` contract to compute the conversion (with a small
on-chain "reliability" lottery seeded by recent block hashes).

It's part of a four-contract demo set:

- `0x89205a3a3b2a69de6dbf7f01ed13b2108b2c43e7` — Unicorn token
- `0xED6aC8de7c7CA7e3A22952e09C2a2A1232DDef9A` — Unicorn Meat token (🍖)
- `0x4AB274FC3A81B300A0016b3805d9b94C81FA54d2` — MeatConversionCalculator
- `0xc7e9dDd5358e08417b1C88ed6f1a73149BEeaa32` — **MeatGrindersAssociation** (this one)

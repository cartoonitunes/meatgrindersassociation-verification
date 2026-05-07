/**
 * Verification proof for MeatGrindersAssociation at
 * 0xc7e9dDd5358e08417b1C88ed6f1a73149BEeaa32 (Ethereum Mainnet, block 1,211,176, 2016-03-24).
 *
 * Compiles MeatGrindersAssociation.sol with soljson v0.2.1+commit.91a6b35f (optimizer ON)
 * and compares against on-chain runtime + creation bytecode.
 *
 * Usage:
 *   curl -O https://binaries.soliditylang.org/bin/soljson-v0.2.1+commit.91a6b35f.js
 *   mv soljson-v0.2.1+commit.91a6b35f.js soljson-v0.2.1.js
 *   npm install solc@0.4.26
 *   node verify.js
 */

const fs = require("fs");
const path = require("path");

const solc = require("solc");
const soljson = require(path.join(__dirname, "soljson-v0.2.1.js"));
const compiler = solc.setupMethods(soljson);

const source = fs.readFileSync(path.join(__dirname, "MeatGrindersAssociation.sol"), "utf8");

const onchainRuntime = fs
  .readFileSync(path.join(__dirname, "onchain-runtime.hex"), "utf8")
  .trim()
  .replace(/^0x/, "")
  .toLowerCase();

const onchainCreation = fs
  .readFileSync(path.join(__dirname, "onchain-creation.hex"), "utf8")
  .trim()
  .replace(/^0x/, "")
  .toLowerCase();

const result = compiler.compile(source, 1);

if (result.errors && result.errors.some((e) => /Error/i.test(e))) {
  console.error("Compilation errors:");
  for (const e of result.errors) console.error(" ", e);
  process.exit(1);
}

const c = result.contracts["MeatGrindersAssociation"];
const compiledRuntime = c.runtimeBytecode.toLowerCase();
const compiledCreation = c.bytecode.toLowerCase();

console.log("Compiler:  soljson v0.2.1+commit.91a6b35f");
console.log("Optimizer: ON");
console.log("");

let ok = true;

console.log("Runtime  - compiled:", compiledRuntime.length / 2, "bytes; on-chain:", onchainRuntime.length / 2, "bytes");
if (compiledRuntime === onchainRuntime) {
  console.log("           ✅ EXACT MATCH");
} else {
  console.log("           ❌ MISMATCH");
  ok = false;
}

const creationPrefix = onchainCreation.slice(0, compiledCreation.length);
const constructorArgs = onchainCreation.slice(compiledCreation.length);
console.log("");
console.log("Creation - compiled:", compiledCreation.length / 2, "bytes; on-chain prefix:", creationPrefix.length / 2, "bytes");
if (creationPrefix === compiledCreation) {
  console.log("           ✅ EXACT MATCH (deploy bytecode)");
  console.log("");
  console.log("Constructor args (", constructorArgs.length / 2, "bytes ):");
  for (let i = 0; i < constructorArgs.length; i += 64) {
    console.log("  0x" + constructorArgs.slice(i, i + 64));
  }
  console.log("");
  console.log("  unicornAddress             = 0x89205a3a3b2a69de6dbf7f01ed13b2108b2c43e7");
  console.log("  meatAddress                = 0xed6ac8de7c7ca7e3a22952e09c2a2a1232ddef9a");
  console.log("  minimumUnicornsToPassAVote = 1");
  console.log("  minutesForDebate           = 0");
  console.log("  multiplierForVotesAgainst  = 4");
  console.log("  meatCalculator             = 0x4ab274fc3a81b300a0016b3805d9b94c81fa54d2");
} else {
  console.log("           ❌ MISMATCH");
  ok = false;
}

if (!ok) process.exit(1);

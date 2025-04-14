# ❄️ zkvault-classic

This project is both a self-learning and teaching initiative, aimed at exploring and implementing zk-SNARKs in a vault system.

It is an upgraded version of the [zkvault-basic](https://github.com/zekele-win/zkvault-basic), utilizing a Merkle Tree to separate the deposit and withdraw addresses, providing enhanced privacy and security in the system

This project is a simplified version of [Tornado Cash classic](https://github.com/tornadocash/tornado-core).

---

## ✨ Feature Overview

### Deposit

Users can deposit funds into the vault.

When a deposit is made, a unique commitment is created and stored on the blockchain.

This commitment is linked to the user’s deposit address via the Merkle Tree, ensuring privacy.

### Withdrawal

Users can withdraw funds from the vault.

The withdrawal process requires a valid nullifier to prove ownership without revealing the user’s original deposit address.

The Merkle Tree ensures that the withdrawal address is decoupled from the deposit address, maintaining privacy.

---

## Design Philosophy

1. **Consistency**  
   The system ensures that all operations (deposit, withdraw) are consistent across the blockchain. Every transaction is verified and recorded, guaranteeing that the state of the vault is always up-to-date and reliable.

2. **Security**  
   The design leverages cryptographic proofs and Merkle Trees to secure user funds. By using zero-knowledge proofs (ZKPs), the system ensures that only valid transactions are processed, and all sensitive data remains protected from unauthorized access.

3. **Privacy**  
   Privacy is a core focus. By decoupling the deposit address from the withdrawal address via Merkle Tree-based commitments, users can perform operations without revealing their identities or the transaction history, ensuring complete privacy.

### Limitations

One of the main limitations of this design lies in the fact that both the contract and circuit code are public.

By obtaining all the `msg.data` from the contract's `deposit` and `withdraw` functions, it’s possible to reconstruct all the commitments and roots.

This can be done through offline computation, allowing an attacker to link the deposit address with the withdraw address.

Essentially, all commitments and roots can be matched, which compromises the privacy aspect.

This is a similar privacy issue to what is seen in the classic Tornado Cash implementation.

---

## 🧱 Project Structure

```bash
.
├── circuits/                          # Circom ZK circuits
│   ├── MerkleTree.circom              # Circuit for Merkle Tree implementation
│   ├── PedersenHasher.circom          # Circuit for Pedersen hash implementation
│   └── ZkVaultClassic.circom          # Main circuit implementing deposit/withdraw logic
│
├── contracts/                         # Solidity smart contracts
│   ├── MerkleTree.sol                 # Merkle Tree logic library
│   ├── MerkleTreeWrapper.sol          # Wrapper contract for interacting with Merkle Tree using to test
│   ├── MiMC.sol                       # MiMC hash function library
│   ├── MiMCWrapper.sol                # Wrapper for interacting with MiMC hash using to test
│   ├── ZkVaultClassic.sol             # ZK-enabled Vault contract that supports deposit/withdraw
│   └── ZkVaultClassicVerifier.sol     # Auto-generated Groth16 verifier contract for ZK-proof validation
│
├── scripts/                           # CLI and deployment scripts
│   ├── cli.ts                         # Command-line interface for testing deposit/withdraw operations
│   └── deploy.ts                      # Deploys contracts to local or testnet environments
│
├── test/                              # Tests for circuits and contracts
│   ├── utils.hex.test.ts              # Unit tests for hex encoding utilities
│   ├── utils.pedersen.test.ts         # Unit tests for Pedersen hash implementation
│   ├── ZkVaultClassic.circom.test.ts  # Tests for circuit correctness and witness verification
│   ├── MerkleTree.sol.test.ts         # Unit tests for Merkle Tree smart contract
│   ├── MiMC.sol.test.ts               # Unit tests for MiMC smart contract
│   └── ZkVaultClassic.sol.test.ts     # Tests for smart contract behavior and proof validation
│
├── types/                             # Type declarations for external JS/TS libraries
│   ├── circom_tester.d.ts             # Type definitions for circom_tester (circuit testing wrapper)
│   └── ffjavascript.d.ts              # Type definitions for ffjavascript (bigint/buffer utilities)
│
├── utils/                             # Utility modules used across scripts and tests
│   ├── hex.ts                         # Helpers for hex encoding/decoding
│   ├── merkle-tree.ts                 # Utilities for Merkle Tree operations
│   └── pedersen.ts                    # Pedersen hash implementation, compatible with Circom
│
├── .mocharc.json                      # Mocha configuration for running tests
├── hardhat.config.ts                  # Hardhat configuration for smart contract compilation/deployment
├── package.json                       # Project dependencies and scripts
└── tsconfig.json                      # TypeScript configuration
```

---

## ⚙️ Prerequisites

1. Install Node.js (recommended version: **v22**)
2. Install Circom 2  
   Installation guide: [https://docs.circom.io/getting-started/installation/](https://docs.circom.io/getting-started/installation/)
   ```bash
   circom --version
   ```
3. Install Anvil (local testnet tool)  
   Installation: [https://github.com/foundry-rs/foundry](https://github.com/foundry-rs/foundry)

---

## 📦 Install Dependencies

```bash
npm install
```

---

## 🔧 Build Circuits

Generate `r1cs` and `wasm` files:

```bash
npm run build
```

---

## 🔐 Setup Circuits (Trusted Setup)

Precondition: Download `powersOfTau28_hez_final_18.ptau` and place it in the project root.

- Download: [https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_18.ptau](https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_18.ptau)
- If the link is broken, refer to [iden3/snarkjs](https://github.com/iden3/snarkjs?tab=readme-ov-file#7-prepare-phase-2)

Run setup to generate proving key, verifying key, and Solidity verifier:

```bash
npm run setup
```

---

## 📄 Compile Smart Contracts

Compile Vault and Verifier contracts to EVM-compatible bytecode:

```bash
npm run compile
```

---

## 🧪 Run Tests

Includes Circom circuit tests and Solidity contract tests:

```bash
npm run test
```

---

## 🚀 Start Local Testnet (Anvil)

Default endpoint: `http://127.0.0.1:8545`:

```bash
npm run srv
```

---

## 🧾 Environment Variables (.env)

Create a `.env` file in the root directory, e.g.:

```env
NETWORK = "test"
NODE_URL = "http://127.0.0.1:8545"
MNEMONIC = "<your test mnemonic>"
```

⚠️ The mnemonic is for local testing only. **Do NOT use real wallet credentials!**

---

## 📤 Deploy Contracts to Local Testnet

Deploy the contract with 1 ETH denomination:

```bash
npm run deploy -- --denomination 1
```

---

## 🧭 CLI Commands

### Make a Deposit

```bash
npm run cli -- deposit
```

The command will print a `nullifier` and `secret` — store it securely.

### Make a Withdrawal

Withdraw using the previously printed nullifier and secret:

```bash
npm run cli -- withdraw --nullifier <your-nullifier> --secret <your-secret>
```

---

## 📄 License

This project uses the MIT license. See [LICENSE](./LICENSE) for details.

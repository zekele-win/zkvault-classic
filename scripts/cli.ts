import { program } from "commander";
import dotenv from "dotenv";
dotenv.config();
import assert from "assert";
import path from "path";
import fs from "fs";
import { ethers } from "ethers";
import crypto from "crypto";
import { utils as ffutils } from "ffjavascript";
import * as snarkjs from "snarkjs";
import * as hex from "../utils/hex";
import * as pedersen from "../utils/pedersen";
import * as merkleTree from "../utils/merkle-tree";

/**
 * Generates a wallet from the given mnemonic and derivation index.
 * @param mnemonic The mnemonic phrase.
 * @param index The wallet index in the HD derivation path.
 * @param provider An ethers JsonRpcProvider instance.
 * @returns A Wallet instance connected to the provider.
 */
function generateWallet(
  mnemonic: string,
  index: number,
  provider: ethers.JsonRpcProvider
): ethers.Wallet {
  const hdAallet = ethers.HDNodeWallet.fromPhrase(
    mnemonic,
    undefined,
    `m/44'/60'/0'/0/${index}`
  );
  return new ethers.Wallet(hdAallet.privateKey, provider);
}

/**
 * Retrieves the deployed vault contract block address for a specific network.
 * @param network The target network name (e.g., "mainnet", "sepolia", "test").
 * @returns The deployed contract block and address.
 */
function getVaultContractInfo(network: string): {
  block: number;
  address: string;
} {
  const filePath = path.join(
    __dirname,
    `../artifacts/deployments/${network}/ZkVaultClassic.json`
  );
  const { address, block } = JSON.parse(fs.readFileSync(filePath, "utf8"));
  return { address, block };
}

/**
 * Loads the ABI for the ZkVaultClassic contract.
 * @returns The contract ABI array.
 */
function getVaultContractAbi(): any[] {
  const filePath = path.join(
    __dirname,
    `../artifacts/abis/ZkVaultClassic.json`
  );
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

/**
 * Prints the ETH balances of specified wallet addresses.
 * @param tag A label for the current balance snapshot (e.g., "Before deposit").
 * @param provider An ethers.js provider.
 * @param wallets A record of label => address.
 */
async function printBalances(
  tag: string,
  provider: ethers.JsonRpcProvider,
  wallets: Record<string, string>
) {
  console.log(`[${tag}]`);
  for (const [label, address] of Object.entries(wallets)) {
    const balance = await provider.getBalance(address);
    console.log(`${label}: ${ethers.formatEther(balance)} ETH`);
  }
}

/**
 * Executes the deposit operation into the zkVault contract.
 * Generates a random secret, computes a Pedersen commitment,
 * and sends ETH into the vault with that commitment.
 */
async function deposit() {
  const network = process.env.NETWORK as string;
  const nodeUrl = process.env.NODE_URL as string;
  const mnemonic = process.env.MNEMONIC as string;

  const provider = new ethers.JsonRpcProvider(nodeUrl);

  const depositWallet = generateWallet(mnemonic, 0, provider);
  console.log({ depositWallet });

  const { address: vaultContractAddress } = getVaultContractInfo(network);
  const vaultContractAbi = getVaultContractAbi();

  const vaultContract = new ethers.Contract(
    vaultContractAddress,
    vaultContractAbi,
    depositWallet
  );

  // Generate a 31-byte random nullifier as bigint
  const nullifier = ffutils.leBuff2int(crypto.randomBytes(31));
  console.log({ nullifier });

  // Generate a 31-byte random secret as bigint
  const secret = ffutils.leBuff2int(crypto.randomBytes(31));
  console.log({ secret });

  // Compute the Pedersen commitment for the nullifier + secret
  const commitment = await pedersen.hash(
    Buffer.concat([
      ffutils.leInt2Buff(nullifier, 31),
      ffutils.leInt2Buff(secret, 31),
    ])
  );
  console.log({ commitment });

  // Fetch the vault's deposit denomination
  const denomination = await vaultContract.denomination();
  console.log({ denomination: ethers.formatEther(denomination) });

  // Print balances before the deposit
  await printBalances("Before deposit", provider, {
    depositWallet: depositWallet.address,
    vaultContract: await vaultContract.getAddress(),
  });

  // Perform the deposit transaction
  const tx = await vaultContract.deposit(hex.from(commitment), {
    value: denomination,
    gasLimit: 5_000_000,
    maxFeePerGas: ethers.parseUnits("50", "gwei"),
    maxPriorityFeePerGas: ethers.parseUnits("2", "gwei"),
  });
  console.log({ tx });
  const receipt = await tx.wait();
  console.log({ receipt });

  // Print balances after the deposit
  await printBalances("After deposit", provider, {
    depositWallet: depositWallet.address,
    vaultContract: await vaultContract.getAddress(),
  });

  console.log(
    `Depost successful with: ${JSON.stringify(
      {
        nullifier: nullifier.toString(),
        secret: secret.toString(),
        commitment: commitment.toString(),
      },
      null,
      2
    )}`
  );

  process.exit(0);
}

/**
 * Executes the withdrawal operation from the zkVault contract.
 * Requires a valid nullifier and secret from a previous deposit.
 * Proves knowledge of the secret via zkSNARK and transfers funds to the recipient.
 * @param nullifier The original deposit nullifier (bigint).
 * @param secret The original deposit secret (bigint).
 */
async function withdraw(nullifier: bigint, secret: bigint) {
  console.log({ nullifier, secret });

  const network = process.env.NETWORK as string;
  const nodeUrl = process.env.NODE_URL as string;
  const mnemonic = process.env.MNEMONIC as string;

  const provider = new ethers.JsonRpcProvider(nodeUrl);

  const withdrawWallet = generateWallet(mnemonic, 1, provider);
  const recipientWallet = generateWallet(mnemonic, 2, provider);
  console.log({ withdrawWallet, recipientWallet });

  const { address: vaultContractAddress, block: vaultContractBlock } =
    getVaultContractInfo(network);
  const vaultContractAbi = getVaultContractAbi();

  const vaultContract = new ethers.Contract(
    vaultContractAddress,
    vaultContractAbi,
    withdrawWallet
  );

  // Recompute the commitment from the given secret
  const commitment = await pedersen.hash(
    Buffer.concat([
      ffutils.leInt2Buff(nullifier, 31),
      ffutils.leInt2Buff(secret, 31),
    ])
  );
  console.log({ commitment });

  // Find all the commitments before our commitment including  our commitment
  let found = false;
  const commitments = [];
  for (let i = 0n; ; ++i) {
    const theCommitment = await vaultContract.getCommitment(i);
    if (theCommitment === 0n) break;
    commitments.push(theCommitment);
    if (theCommitment === commitment) {
      found = true;
      break;
    }
  }
  assert(found, "The commitment does not existed.");
  console.log({ commitments });

  // Get levels from the vault contract
  const levels = Number(await vaultContract.levels());
  console.log({ levels });

  // Compute the arguments for computing circuit prrof
  const nullifierHash = await pedersen.hash(nullifier);
  const tree = await merkleTree.create(
    levels,
    commitments.map((c) => c.toString())
  );
  const root = BigInt(tree.root);
  const treepath = tree.path(commitments.length - 1);
  const pathElements = treepath.pathElements.map((c) => BigInt(c));
  const pathIndices = treepath.pathIndices.map((c) => BigInt(c));

  // Check if the root existed in the vault
  assert(await vaultContract.isKnownRoot(root), "The root does not existed.");

  // Compute circuit prrof
  const { proof, publicSignals } = await snarkjs.groth16.fullProve(
    {
      // Public inputs
      root,
      nullifierHash,
      recipient: BigInt(recipientWallet.address),

      // Private inputs
      nullifier,
      secret,
      pathElements,
      pathIndices,
    },
    path.join(__dirname, "../build/ZkVaultClassic_js/ZkVaultClassic.wasm"),
    path.join(__dirname, "../build/ZkVaultClassic.zkey")
  );
  console.log({ proof, publicSignals });

  // Print balances before the withdrawal
  await printBalances("Before withdraw", provider, {
    withdrawWallet: withdrawWallet.address,
    recipientWallet: recipientWallet.address,
    vaultContract: await vaultContract.getAddress(),
  });

  // Perform the withdrawal using the generated zk proof
  const tx = await vaultContract.withdraw(
    [BigInt(proof.pi_a[0]), BigInt(proof.pi_a[1])],
    [
      [BigInt(proof.pi_b[0][1]), BigInt(proof.pi_b[0][0])],
      [BigInt(proof.pi_b[1][1]), BigInt(proof.pi_b[1][0])],
    ],
    [BigInt(proof.pi_c[0]), BigInt(proof.pi_c[1])],
    [
      BigInt(publicSignals[0]),
      BigInt(publicSignals[1]),
      BigInt(publicSignals[2]),
    ]
  );
  console.log({ tx });
  const receipt = await tx.wait();
  console.log({ receipt });

  // Print balances after the withdrawal
  await printBalances("After withdraw", provider, {
    withdrawWallet: withdrawWallet.address,
    recipientWallet: recipientWallet.address,
    vaultContract: await vaultContract.getAddress(),
  });

  console.log(
    `Withdraw successful with: ${JSON.stringify(
      {
        nullifier: nullifier.toString(),
        secret: secret.toString(),
        commitment: commitment.toString(),
      },
      null,
      2
    )}`
  );

  process.exit(0);
}

/**
 * Entry point using Commander to parse options.
 * Supports `deposit` and `withdraw` commands.
 */
async function main() {
  program.description("zkvault-classic CLI");

  program
    .command("deposit")
    .description("Deposit ETH into the vault.")
    .action(async () => {
      await deposit();
    });

  program
    .command("withdraw")
    .description("Withdraw ETH from the vault.")
    .option(
      "--nullifier <nullifier>",
      "The returned nullifier when you deposit.",
      (value) => BigInt(value)
    )
    .option(
      "--secret <secret>",
      "The returned secret when you deposit.",
      (value) => BigInt(value)
    )
    .action(async (opts) => {
      await withdraw(opts.nullifier, opts.secret);
    });

  program.parse();
}

main();

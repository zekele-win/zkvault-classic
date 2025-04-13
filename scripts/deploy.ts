import { program } from "commander";
import dotenv from "dotenv";
dotenv.config();
import path from "path";
import fs from "fs";
import { BytesLike, ethers } from "ethers";

const LEVELS = 10n;
const ROOT_SIZE = 100n;

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
  const hdWallet = ethers.HDNodeWallet.fromPhrase(
    mnemonic,
    undefined,
    `m/44'/60'/0'/0/${index}`
  );
  return new ethers.Wallet(hdWallet.privateKey, provider);
}

/**
 * Loads the ABI and bytecode from compiled contract artifacts.
 * @param fileName The Solidity source file name (without extension).
 * @param contractName The name of the contract.
 * @returns An object containing the contract ABI and bytecode.
 */
function getContractInfo(fileName: string, contractName: string): any {
  const filePath = path.join(
    __dirname,
    `../artifacts/contracts/${fileName}.sol/${contractName}.json`
  );
  const artifact = JSON.parse(fs.readFileSync(filePath, "utf8"));
  return {
    abi: artifact.abi,
    bytecode: artifact.bytecode,
  };
}

/**
 * Deploys a contract using the provided wallet, ABI, and bytecode.
 * @param wallet The deployer's Wallet instance.
 * @param abi The contract's ABI.
 * @param bytecode The contract's bytecode.
 * @param args The constructor arguments for the contract.
 * @returns A deployed BaseContract instance.
 */
async function deployContract(
  wallet: ethers.Wallet,
  abi: any[],
  bytecode: BytesLike,
  ...args: ethers.ContractMethodArgs<any[]>
): Promise<{
  contract: ethers.BaseContract;
  receipt: ethers.ContractTransactionReceipt;
}> {
  const contractFactory = new ethers.ContractFactory(abi, bytecode, wallet);
  const contract = await contractFactory.deploy(...args, {
    gasLimit: 5_000_000,
    maxFeePerGas: ethers.parseUnits("50", "gwei"),
    maxPriorityFeePerGas: ethers.parseUnits("2", "gwei"),
  });
  await contract.waitForDeployment();

  const tx = contract.deploymentTransaction();
  console.log({ tx });

  const receipt = await tx!.wait();
  console.log({ receipt });

  return { contract, receipt: receipt as ethers.ContractTransactionReceipt };
}

/**
 * Saves deployment metadata to a JSON file.
 * @param network The network name (e.g., "mainnet", "sepolia", "test").
 * @param name The contract name.
 * @param deployBlock The block number where the contract deployed.
 * @param contractAddress The deployed contract address.
 * @param deployerAddress The address that deployed the contract.
 */
function saveDeployment(
  network: string,
  name: string,
  deployBlock: number,
  contractAddress: string,
  deployerAddress: string
) {
  const deployment = {
    block: deployBlock,
    address: contractAddress,
    deployer: deployerAddress,
    timestamp: new Date().toISOString(),
  };

  const filePath = path.join(
    __dirname,
    `../artifacts/deployments/${network}/${name}.json`
  );
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(deployment, null, 2));
}

/**
 * Saves the contract ABI to a local file.
 * @param name The contract name.
 * @param abi The contract ABI.
 */
function saveAbi(name: string, abi: any[]) {
  const filePath = path.join(__dirname, `../artifacts/abis/${name}.json`);
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(abi, null, 2));
}

/**
 * Deploys the verifier contract and the vault contract, and saves metadata.
 * @param denomination The fixed ETH deposit amount for the vault, as a string.
 */
async function deploy(denomination: string) {
  console.log({ denomination });

  const network = process.env.NETWORK as string;
  const nodeUrl = process.env.NODE_URL as string;
  const mnemonic = process.env.MNEMONIC as string;

  const provider = new ethers.JsonRpcProvider(nodeUrl);

  const wallet = generateWallet(mnemonic, 0, provider);
  console.log({ wallet });

  // Deploy verifier contract
  const { abi: verifierContractAbi, bytecode: verifierContractBytecode } =
    getContractInfo("ZkVaultClassicVerifier", "Groth16Verifier");
  const { contract: verifierContract, receipt: verifierContractReceipt } =
    await deployContract(wallet, verifierContractAbi, verifierContractBytecode);
  const verifierContractAddress = verifierContract.target as string;
  const verifierContractDeployBlock = verifierContractReceipt.blockNumber;
  console.log({ verifierContractAddress, verifierContractDeployBlock });

  // Deploy vault contract with the verifier address and denomination
  const { abi: vaultContractAbi, bytecode: vaultContractBytecode } =
    getContractInfo("ZkVaultClassic", "ZkVaultClassic");
  const { contract: vaultContract, receipt: vaultContractReceipt } =
    await deployContract(
      wallet,
      vaultContractAbi,
      vaultContractBytecode,
      verifierContractAddress,
      ethers.parseEther(denomination),
      LEVELS,
      ROOT_SIZE
    );
  const vaultContractAddress = vaultContract.target as string;
  const vaultContractDeployBlock = vaultContractReceipt.blockNumber;
  console.log({ vaultContractAddress, vaultContractDeployBlock });

  // Save contract info
  saveDeployment(
    network,
    "ZkVaultClassicVerifier",
    verifierContractDeployBlock,
    verifierContractAddress,
    wallet.address
  );
  saveDeployment(
    network,
    "ZkVaultClassic",
    vaultContractDeployBlock,
    vaultContractAddress,
    wallet.address
  );
  saveAbi("ZkVaultClassicVerifier", verifierContractAbi);
  saveAbi("ZkVaultClassic", vaultContractAbi);

  console.log(
    `Deploy successful with: ${JSON.stringify(
      {
        verifierContractAddress,
        vaultContractAddress,
      },
      null,
      2
    )}`
  );
}

/**
 * Entry point using Commander to parse options.
 */
async function main() {
  program
    .description("zkvault-classic deployer.")
    .option("--denomination <denomination>", "ETH amount to deposit, e.g. 0.1.")
    .action(async (opts) => {
      await deploy(opts.denomination);
    });

  program.parse();
}

main();

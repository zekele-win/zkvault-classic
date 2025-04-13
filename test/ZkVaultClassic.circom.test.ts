import { expect } from "chai";
import { wasm, WasmTester } from "circom_tester";
import { utils as ffutils } from "ffjavascript";
import * as pedersen from "../utils/pedersen";
import * as merkleTree from "../utils/merkle-tree";

describe("ZkVaultClassic _circuit", () => {
  let _circuit: WasmTester;

  const LEVELS = 20;

  async function createWitness(
    nullifier: bigint,
    secret: bigint,
    recipient: bigint,
    dummyLeafCount: number = 5
  ): Promise<{ [key: string]: bigint | bigint[] }> {
    const nullifierHash = await pedersen.hash(nullifier);
    const commitment = await pedersen.hash(
      Buffer.concat([
        ffutils.leInt2Buff(nullifier, 31),
        ffutils.leInt2Buff(secret, 31),
      ])
    );

    const dummyLeaves = Array.from({ length: dummyLeafCount }, (_, i) =>
      BigInt((i + 1) * 17)
    );
    const leaves = [...dummyLeaves, commitment].map((x) => x.toString());

    const tree = await merkleTree.create(LEVELS, leaves);
    const { pathElements, pathIndices } = tree.path(leaves.length - 1);
    const root = tree.root;

    return {
      root: BigInt(root),
      nullifierHash,
      recipient,
      nullifier,
      secret,
      pathElements: pathElements.map(BigInt),
      pathIndices: pathIndices.map(BigInt),
    };
  }

  before(async () => {
    _circuit = await wasm("./circuits/ZkVaultClassic.circom");
  });

  it("should correctly output consistent root and recipient.", async () => {
    const witnessInput = await createWitness(123n, 456n, 789n);
    const witness = await _circuit.calculateWitness(witnessInput, true);
    await _circuit.assertOut(witness, { rootOut: witnessInput.root });
    await _circuit.assertOut(witness, { recipientOut: witnessInput.recipient });
  });

  it("should correctly output consistent root and recipient with long tree.", async () => {
    const witnessInput = await createWitness(123n, 456n, 789n, 500);
    const witness = await _circuit.calculateWitness(witnessInput, true);
    await _circuit.assertOut(witness, { rootOut: witnessInput.root });
    await _circuit.assertOut(witness, { recipientOut: witnessInput.recipient });
  });

  it("should throw error if nullifier = 0n.", async () => {
    const witnessInput = await createWitness(0n, 456n, 789n);
    await expect(
      _circuit.calculateWitness(witnessInput, true)
    ).to.be.rejectedWith(Error, /Assert Failed/);
  });

  it("should throw error if secret = 0n.", async () => {
    const witnessInput = await createWitness(123n, 0n, 789n);
    await expect(
      _circuit.calculateWitness(witnessInput, true)
    ).to.be.rejectedWith(Error, /Assert Failed/);
  });

  it("should throw error if recipient = 0n.", async () => {
    const witnessInput = await createWitness(123n, 456n, 0n);
    await expect(
      _circuit.calculateWitness(witnessInput, true)
    ).to.be.rejectedWith(Error, /Assert Failed/);
  });

  it("should throw error if pathElements is incorrect.", async () => {
    const witnessInput = await createWitness(123n, 456n, 789n);
    witnessInput.pathElements = [...Array(LEVELS)].map((_, i) =>
      BigInt((i + 2) ** 3)
    );
    await expect(
      _circuit.calculateWitness(witnessInput, true)
    ).to.be.rejectedWith(Error, /Assert Failed/);
  });

  it("should throw error if pathIndices is not in [0,1].", async () => {
    const witnessInput = await createWitness(123n, 456n, 789n);
    witnessInput.pathIndices = [...Array(LEVELS)].map((_, i) =>
      BigInt((i + 2) ** 3)
    );
    await expect(
      _circuit.calculateWitness(witnessInput, true)
    ).to.be.rejectedWith(Error, /Assert Failed/);
  });

  it("should throw error if pathIndices is incorrect.", async () => {
    const witnessInput = await createWitness(123n, 456n, 789n);
    witnessInput.pathIndices = [...Array(LEVELS)].map((_, i) => BigInt(i % 2));
    await expect(
      _circuit.calculateWitness(witnessInput, true)
    ).to.be.rejectedWith(Error, /Assert Failed/);
  });

  it("should throw error if root is incorrect.", async () => {
    const witnessInput = await createWitness(123n, 456n, 789n);
    witnessInput.root = (witnessInput.root as bigint) + 1n;
    await expect(
      _circuit.calculateWitness(witnessInput, true)
    ).to.be.rejectedWith(Error, /Assert Failed/);
  });
});

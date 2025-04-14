import { expect } from "chai";
import { ethers } from "hardhat";
import { MerkleTreeWrapper } from "../typechain-types";
import * as merkleTree from "../utils/merkle-tree";

describe("MerkleTree contract", function () {
  async function deployContract(levels: bigint): Promise<MerkleTreeWrapper> {
    return await (
      await ethers.getContractFactory("MerkleTreeWrapper")
    ).deploy(levels);
  }

  describe("initialize", function () {
    it("should correctly initialize.", async function () {
      const contract = await deployContract(10n);
      expect(await contract.getAddress()).to.be.properAddress;
    });

    it("should revert if initialize with invalid levels.", async function () {
      await expect(deployContract(0n)).to.revertedWith(
        "Merkle tree levels must be [1, 32]"
      );
      await expect(deployContract(33n)).to.revertedWith(
        "Merkle tree levels must be [1, 32]"
      );
    });
  });

  describe("insertLeaf", function () {
    it("should correctly insert a leaf and return an index.", async function () {
      const contract = await deployContract(10n);
      const leaves = [11n, 22n, 33n];
      for (const [index, leaf] of leaves.entries()) {
        await expect(contract.insertLeaf(leaf))
          .to.emit(contract, "LeafInserted")
          .withArgs(index, leaf);
      }
    });

    it("should revert if insert a leaf while the tree if full.", async function () {
      const levels = 3n;
      const contract = await deployContract(levels);

      const maxLeafCount = 2n ** levels - 1n;
      for (let index = 0n; index <= maxLeafCount; ++index) {
        await contract.insertLeaf((index + 1n) ** 2n);
      }

      await expect(contract.insertLeaf(1234n)).to.revertedWith(
        "Merkle tree is full"
      );
    });
  });

  describe("isKnownRoot", function () {
    it("should sucessfully check the root after insert a leaf.", async function () {
      const levels = 10n;
      const contract = await deployContract(levels);

      const leaves: bigint[] = [];
      const roots: bigint[] = [];
      for (let i = 0n; i < 10n; ++i) {
        const l = (i + 1n) ** 2n;

        const tx = await contract.insertLeaf(l);
        const receipt = await tx.wait();

        const [index, leaf] = contract.interface.parseLog(
          receipt!.logs[0]
        )!.args;
        // console.log({ index, leaf });
        leaves.push(leaf);

        const tree = await merkleTree.create(
          Number(levels),
          leaves.map((c) => c.toString())
        );
        const root = BigInt(tree.root);
        // console.log({ root });
        roots.push(root);
      }

      for (const root of roots) {
        expect(await contract.isKnownRoot(root)).to.true;
      }
    });

    it("should failed check the root before insert a leaf.", async function () {
      const contract = await deployContract(10n);
      expect(await contract.isKnownRoot(1234n)).to.false;
    });
  });
});

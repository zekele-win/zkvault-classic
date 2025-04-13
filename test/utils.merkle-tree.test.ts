import { expect } from "chai";
import { buildMimcSponge } from "circomlibjs";
import { MerkleTree } from "fixed-merkle-tree";
import * as merkleTree from "../utils/merkle-tree";

async function manualHash(left: string, right: string): Promise<string> {
  const mimc = await buildMimcSponge();
  const hash = mimc.multiHash([BigInt(left), BigInt(right)]);
  return mimc.F.toObject(hash).toString();
}

describe("utils/merkle-tree", () => {
  describe("create()", () => {
    it("should correctly create a merkle tree with certain leaves.", async () => {
      const levels = 5;
      const leaves = [...Array(2 ** levels)]
        .map((_, i) => (i + 1) ** 2)
        .map(String);
      const tree = await merkleTree.create(levels, leaves);

      expect(tree).to.instanceOf(MerkleTree);
      expect(tree.levels).to.equal(levels);

      const manualRoots = [...leaves];
      for (let i = 0; i < levels; ++i) {
        const length = 2 ** (levels - i);
        for (let j = 0; j < length / 2; ++j) {
          manualRoots[j] = await manualHash(
            manualRoots[j * 2],
            manualRoots[j * 2 + 1]
          );
        }
      }
      expect(tree.root).to.equal(manualRoots[0]);
    });
  });
});

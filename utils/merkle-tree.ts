import { buildMimcSponge, MimcSponge } from "circomlibjs";
import { MerkleTree, Element } from "fixed-merkle-tree";

let mimc: MimcSponge;

function mimcHash(left: Element, right: Element): string {
  // Calc hash.
  const hash = mimc.multiHash([BigInt(left), BigInt(right)]);
  // Make sure hash < BN254.
  return mimc.F.toObject(hash).toString();
}

// keccak256("zkvault-classic") % BN254_FIELD_SIZE
const ZERO_ELEMENT =
  10963288431021815655612693718125944876066744931256163158756426137396928311292n;

export async function create(
  levels: number,
  leaves: Element[]
): Promise<MerkleTree> {
  if (!mimc) mimc = await buildMimcSponge();
  return new MerkleTree(levels, leaves, {
    hashFunction: mimcHash,
    zeroElement: ZERO_ELEMENT.toString(),
  });
}

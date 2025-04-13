import { utils as ffutils } from "ffjavascript";
import { buildPedersenHash } from "circomlibjs";

/**
 * Computes the Pedersen hash of the given input.
 *
 * Internally uses `circomlibjs` to hash data to a point on BabyJubJub curve,
 * and then returns the x-coordinate of the resulting point as the final hash.
 *
 * @param {Uint8Array | bigint} data - The input data to hash. If bigint,
 *   it's converted to 31-byte little-endian buffer.
 * @returns {Promise<bigint>} The x-coordinate of the Pedersen point,
 *   as a field element (mod BN254).
 */
export async function hash(data: Uint8Array | bigint): Promise<bigint> {
  if (typeof data === "bigint") {
    // Convert bigint to 31-byte little-endian buffer (to fit BabyJubJub input spec)
    data = ffutils.leInt2Buff(data, 31);
  } else if (!(data instanceof Uint8Array)) {
    throw new TypeError("Unsupported data type");
  }

  const pedersen = await buildPedersenHash();

  // Compute the Pedersen hash point on BabyJubJub curve
  const hashPoint = pedersen.babyJub.unpackPoint(pedersen.hash(data));

  // Return the x-coordinate of the point, as a field element
  return pedersen.babyJub.F.toObject(hashPoint[0]);
}

/**
 * Converts a Uint8Array, bigint, or decimal string into a hex string with "0x" prefix.
 *
 * @param {Uint8Array | bigint | string} data - The input to convert. Accepts:
 *   - Uint8Array (raw bytes)
 *   - bigint
 *   - string (must be a valid decimal string)
 * @param {number} [length=32] - Desired byte length of output (used for zero-padding).
 * @returns {string} Hexadecimal string representation prefixed with "0x".
 * @throws {Error} Throws if input type is unsupported or string is not a valid number.
 */
export function from(
  data: Uint8Array | bigint | string,
  length: number = 32
): string {
  let hex: string;

  if (data instanceof Uint8Array) {
    hex = Buffer.from(data).toString("hex");
  } else if (typeof data === "bigint") {
    hex = data.toString(16);
  } else if (typeof data === "string") {
    try {
      hex = BigInt(data).toString(16);
    } catch {
      throw new Error("Invalid numeric string provided.");
    }
  } else {
    throw new Error("Unsupported data type.");
  }

  return "0x" + hex.padStart(length * 2, "0");
}

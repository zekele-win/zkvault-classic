/**
 * @module ffjavascript
 * @description TypeScript declarations for utility functions in the `ffjavascript` library.
 * This module provides helpers for converting between `bigint` and byte buffers,
 * as well as serialization utilities for `bigint` values.
 */
declare module "ffjavascript" {
  export namespace utils {
    /**
     * Converts a little-endian buffer to a bigint.
     *
     * This function interprets the given buffer as a little-endian
     * encoded integer and converts it into a `bigint`.
     *
     * @param {Uint8Array} buff - The little-endian encoded buffer.
     * @returns {bigint} The corresponding bigint representation.
     */
    function leBuff2int(buff: Uint8Array): bigint;

    /**
     * Converts a bigint to a little-endian byte buffer.
     *
     * @param {bigint} n - The bigint to convert.
     * @param {number} len - The desired byte length of the resulting buffer.
     * @returns {Uint8Array} A Uint8Array containing the little-endian encoding of the bigint.
     */
    function leInt2Buff(n: bigint, len: number): Uint8Array;

    /**
     * Converts a big-endian buffer to a bigint.
     *
     * This function interprets the given buffer as a big-endian
     * encoded integer and converts it into a `bigint`.
     *
     * @param {Uint8Array} buff - The big-endian encoded buffer.
     * @returns {bigint} The corresponding bigint representation.
     */
    function beBuff2int(buff: Uint8Array): bigint;

    /**
     * Converts a bigint to a big-endian byte buffer.
     *
     * @param {bigint} n - The bigint to convert.
     * @param {number} len - The desired byte length of the resulting buffer.
     * @returns {Uint8Array} A Uint8Array containing the big-endian encoding of the bigint.
     */
    function beInt2Buff(n: bigint, len: number): Uint8Array;

    /**
     * Recursively converts all BigInt values within an object into strings.
     *
     * This is useful for safely serializing BigInts with `JSON.stringify`, which does not support BigInts natively.
     *
     * @param o - An object or value that may contain BigInt values.
     * @returns A deep copy of the input where all BigInt values are converted to strings.
     */
    function stringifyBigInts<T = any>(o: T): any;

    /**
     * Recursively converts all stringified integers within an object back into BigInt values.
     *
     * This complements `stringifyBigInts` and is useful when deserializing objects from JSON.
     *
     * @param o - An object or value that may contain stringified BigInt values.
     * @returns A deep copy of the input where all numeric strings are converted back into BigInts.
     */
    function unstringifyBigInts<T = any>(o: T): any;
  }
}

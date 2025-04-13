/**
 * @module circom_tester
 * @description Type definitions for the circom_tester module
 * This module provides interfaces for testing Circom circuits using WASM
 */
declare module "circom_tester" {
  /**
   * Interface representing a WebAssembly-based Circom circuit tester.
   */
  export interface WasmTester {
    /**
     * Calculates the witness (intermediate and output signals) for the circuit
     * given an input object.
     *
     * @param input - An object mapping input signal names to their BigInt values.
     * @param sanityCheck - If true, performs additional checks during witness calculation.
     * @returns A Promise that resolves to an array of BigInt values representing the full witness.
     */
    calculateWitness(
      input: { [key: string]: bigint[] | bigint },
      sanityCheck: boolean
    ): Promise<bigint[]>;

    /**
     * Extracts output signals from a full witness.
     *
     * @param witness - The full witness array returned by `calculateWitness`.
     * @param output - Can be an object (mapping output names to indexes), an array of indexes, or a single index.
     * @returns A Promise resolving to the extracted output values. Format depends on input type:
     *          - Object -> named output map,
     *          - Array -> ordered array of outputs,
     *          - Number -> single output value.
     */
    getOutput(
      witness: bigint[],
      output: { [key: string]: number } | number[] | number
    ): Promise<{ [key: string]: bigint } | bigint[] | bigint>;

    /**
     * Asserts that the actual output matches the expected output.
     * Throws an error if they do not match.
     *
     * @param actualOut - The actual output from the circuit.
     * @param expectedOut - The expected output to compare against.
     * @returns A Promise that resolves if outputs match, or rejects with an error if they don't.
     */
    assertOut(
      actualOut: bigint[],
      expectedOut: { [key: string]: bigint[] | bigint } | bigint[] | bigint
    ): Promise<void>;
  }

  /**
   * Loads a Circom circuit as a WASM tester from a compiled `.wasm` file path.
   *
   * @param filePath - The path to the compiled Circom `.wasm` file.
   * @returns A Promise that resolves to a WasmTester instance.
   */
  export function wasm(filePath: string): Promise<WasmTester>;
}

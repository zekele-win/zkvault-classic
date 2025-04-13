import { expect } from "chai";
import { from } from "../utils/hex";

describe("utils/hex", () => {
  describe("from()", () => {
    it("should correctly convert Uint8Array to hex string", () => {
      const input = Uint8Array.from([0xde, 0xad, 0xbe, 0xef]);
      const result = from(input, input.length);
      expect(result).to.equal("0xdeadbeef");
    });

    it("should correctly pad Uint8Array to specified length", () => {
      const input = Uint8Array.from([0x01]);
      const result = from(input, 2);
      expect(result).to.equal("0x0001");
    });

    it("should correctly convert bigint to hex string with default length", () => {
      const input = 123456789n;
      const result = from(input);
      const expected = "0x" + input.toString(16).padStart(64, "0");
      expect(result).to.equal(expected);
    });

    it("should correctly convert numeric string to hex string", () => {
      const input = "42";
      const result = from(input, 2);
      expect(result).to.equal("0x002a");
    });

    it("should throw when numeric string is not valid", () => {
      const input = "xyz";
      expect(() => from(input)).to.throw();
    });

    it("should throw when input is unsupported type", () => {
      const input = { foo: "bar" } as any;
      expect(() => from(input)).to.throw();
    });
  });
});

import { expect } from "chai";
import { hash } from "../utils/pedersen";

describe("utils/pedersen.hash", () => {
  describe("hash()", () => {
    it("should correctly hash a bigint input", async () => {
      const input = 123456789n;
      const expectedOutput =
        16357009341607164888509856184971824510411102401611643760890649953308605691960n;
      const result = await hash(input);
      // expect(result).to.be.a("bigint");
      // expect(result < (1n << 254n)).to.be.true;
      expect(result).to.equal(expectedOutput);
    });

    it("should correctly hash a Uint8Array input", async () => {
      const input = Uint8Array.from([0xde, 0xad, 0xbe, 0xef]);
      const expectedOutput =
        18636630888149257515818539730433047487495599891476271467337186494769173887924n;
      const result = await hash(input);
      // expect(result).to.be.a("bigint");
      // expect(result < (1n << 254n)).to.be.true;
      expect(result).to.equal(expectedOutput);
    });

    it("should throw on invalid input types", async () => {
      const invalidInputs: any[] = [
        null,
        undefined,
        "123456",
        [1, 2, 3],
        {},
        123,
      ];

      for (const input of invalidInputs) {
        await expect(hash(input)).to.be.rejectedWith(
          TypeError,
          /Unsupported data type/
        );
      }
    });
  });
});

import { expect } from "chai";
import { ethers } from "hardhat";
import { buildMimcSponge } from "circomlibjs";
import { MiMCWrapper } from "../typechain-types";

describe("MiMC contract", function () {
  let _contract: MiMCWrapper;

  async function hashByCircom(left: bigint, right: bigint): Promise<bigint> {
    const mimc = await buildMimcSponge();
    // Calc hash.
    const hash = mimc.multiHash([BigInt(left), BigInt(right)]);
    // Make sure hash < BN254.
    return mimc.F.toObject(hash);
  }

  async function hash(left: bigint, right: bigint): Promise<bigint> {
    return _contract.hashLeftRight(left, right);
  }

  beforeEach(async function () {
    const contractFactory = await ethers.getContractFactory("MiMCWrapper");
    _contract = await contractFactory.deploy();
  });

  describe("deploy", function () {
    it("should correctly deploy.", async function () {
      expect(await _contract.getAddress()).to.be.properAddress;
    });
  });

  describe("hash", function () {
    it("should correctly compute the hash.", async function () {
      const left = 1234n;
      const right = 4567n;
      const result = await hash(left, right);
      const resultExpected = await hashByCircom(left, right);
      expect(result).to.equal(resultExpected);
    });

    it("should correctly compute the hash with big numbers.", async function () {
      const left =
        0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaan;
      const right =
        0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbn;
      const result = await hash(left, right);
      const resultExpected = await hashByCircom(left, right);
      expect(result).to.equal(resultExpected);
    });
  });
});

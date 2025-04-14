import { expect } from "chai";
import { ethers } from "hardhat";
import { buildMimcSponge } from "circomlibjs";
import { MiMCWrapper } from "../typechain-types";

describe("MiMC contract", function () {
  let _contract: MiMCWrapper;

  async function computeAndVerifyHash(
    left: bigint,
    right: bigint
  ): Promise<void> {
    const result = await _contract.hashLeftRight(left, right);

    const mimc = await buildMimcSponge();
    const hash = mimc.multiHash([BigInt(left), BigInt(right)]);
    const expected = mimc.F.toObject(hash);

    expect(result).to.equal(expected);
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
      computeAndVerifyHash(1234n, 4567n);
    });

    it("should correctly compute the hash with big numbers.", async function () {
      computeAndVerifyHash(
        0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaan,
        0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbn
      );
    });

    it("should correctly compute the hash with uint256.min and uint256.max.", async function () {
      computeAndVerifyHash(
        0n,
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn
      );
    });
  });
});

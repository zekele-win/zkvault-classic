import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer } from "ethers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { ZkVaultClassic } from "../typechain-types";
import { utils as ffutils } from "ffjavascript";
import * as snarkjs from "snarkjs";
import * as hex from "../utils/hex";
import * as pedersen from "../utils/pedersen";
import * as merkleTree from "../utils/merkle-tree";

describe("ZkVaultClassic contract", function () {
  const _denomination = ethers.parseEther("1");
  const _levels = 10;
  const _rootSize = 100;

  let _vaultContract: ZkVaultClassic;
  let _ownerAccount: Signer;
  let _guestAccount: Signer;

  async function prepareDeposit(nullifier: bigint, secret: bigint) {
    return await pedersen.hash(
      Buffer.concat([
        ffutils.leInt2Buff(nullifier, 31),
        ffutils.leInt2Buff(secret, 31),
      ])
    );
  }

  async function deposit(commitment: bigint, value: bigint = 0n) {
    return _vaultContract.deposit(hex.from(commitment), { value });
  }

  async function prepareWithdraw(
    nullifier: bigint,
    secret: bigint,
    recipient: bigint,
    commitments: bigint[]
  ) {
    const nullifierHash = await pedersen.hash(nullifier);
    const tree = await merkleTree.create(
      _levels,
      commitments.map((c) => c.toString())
    );
    const root = BigInt(tree.root);
    const path = tree.path(commitments.length - 1);
    const pathElements = path.pathElements.map((c) => BigInt(c));
    const pathIndices = path.pathIndices.map((c) => BigInt(c));

    return {
      root,
      nullifierHash,
      recipient,
      nullifier,
      secret,
      pathElements,
      pathIndices,
    };
  }

  async function withdraw(
    root: bigint,
    nullifierHash: bigint,
    recipient: bigint,
    nullifier: bigint,
    secret: bigint,
    pathElements: bigint[],
    pathIndices: bigint[],
    fakeProof: boolean = false
  ) {
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(
      {
        // Public inputs
        root,
        nullifierHash,
        recipient,

        // Private inputs
        nullifier,
        secret,
        pathElements,
        pathIndices,
      },
      "./circuits/build/ZkVaultClassic_js/ZkVaultClassic.wasm",
      "./circuits/build/ZkVaultClassic.zkey"
    );
    // console.log({ proof, publicSignals });

    return _vaultContract.withdraw(
      [BigInt(proof.pi_a[0]), BigInt(proof.pi_a[1])],
      [
        [BigInt(proof.pi_b[0][1]), BigInt(proof.pi_b[0][0])],
        [BigInt(proof.pi_b[1][1]), BigInt(proof.pi_b[1][0])],
      ],
      [BigInt(proof.pi_c[0]), BigInt(proof.pi_c[1])],
      [
        fakeProof ? 0n : BigInt(publicSignals[0]),
        BigInt(publicSignals[1]),
        BigInt(publicSignals[2]),
        BigInt(publicSignals[3]),
        BigInt(publicSignals[4]),
      ]
    );
  }

  beforeEach(async function () {
    [_ownerAccount, _guestAccount] = await ethers.getSigners();
    // console.log({ _ownerAccount, _guestAccount });

    const verifierContractFactory = await ethers.getContractFactory(
      "Groth16Verifier"
    );
    const verifierContract = await verifierContractFactory.deploy();
    const verifierContractAddress = await verifierContract.getAddress();
    // console.log({ verifierContractAddress });

    const vaultContractFactory = await ethers.getContractFactory(
      "ZkVaultClassic"
    );
    _vaultContract = await vaultContractFactory.deploy(
      verifierContractAddress,
      _denomination,
      _levels,
      _rootSize
    );
  });

  describe("deploy", function () {
    it("should correctly deploy.", async function () {
      expect(await _vaultContract.getAddress()).to.be.properAddress;
    });

    it("should correctly set the denomination.", async function () {
      const denomination = await _vaultContract.denomination();
      expect(denomination).to.equal(_denomination);
    });

    it("should correctly set the levels.", async function () {
      const levels = await _vaultContract.levels();
      expect(levels).to.equal(_levels);
    });

    it("should correctly set the rootSize.", async function () {
      const rootSize = await _vaultContract.rootSize();
      expect(rootSize).to.equal(_rootSize);
    });
  });

  describe("receive", function () {
    it("should revert if the contract received ETH.", async function () {
      await expect(
        _ownerAccount.sendTransaction({
          to: await _vaultContract.getAddress(),
          value: _denomination,
        })
      ).to.be.revertedWith("Use deposit function");
    });
  });

  describe("deposit", function () {
    it("should revert if msg.value lost.", async function () {
      await expect(deposit(await prepareDeposit(123n, 456n))).to.revertedWith(
        "Invalid deposit amount"
      );
    });

    it("should revert if msg.value != denomination.", async function () {
      await expect(
        deposit(await prepareDeposit(123n, 456n), _denomination + 1n)
      ).to.revertedWith("Invalid deposit amount");
    });

    it("should revert if commitment already used.", async function () {
      await deposit(await prepareDeposit(123n, 456n), _denomination);
      await expect(
        deposit(await prepareDeposit(123n, 456n), _denomination)
      ).to.revertedWith("Commitment already used");
    });

    it("should correctly deposit and emit an event.", async function () {
      const commitment = await prepareDeposit(123n, 456n);

      const vaultContractBalnceBefore =
        await _ownerAccount.provider!.getBalance(
          await _vaultContract.getAddress()
        );
      const ownerAccountBalnceBefore = await _ownerAccount.provider!.getBalance(
        await _ownerAccount.getAddress()
      );

      const tx = await deposit(commitment, _denomination);
      expect(tx)
        .to.emit(_vaultContract, "Deposit")
        .withArgs(commitment, 0n, anyValue);

      const receipt = await tx.wait();
      const gasCost = receipt!.gasUsed * receipt!.gasPrice;

      const vaultContractBalnceAfter = await _ownerAccount.provider!.getBalance(
        await _vaultContract.getAddress()
      );
      const ownerAccountBalnceAfter = await _ownerAccount.provider!.getBalance(
        await _ownerAccount.getAddress()
      );

      expect(vaultContractBalnceAfter - vaultContractBalnceBefore).to.equal(
        _denomination
      );
      expect(ownerAccountBalnceBefore - ownerAccountBalnceAfter).to.equal(
        _denomination + gasCost
      );
    });
  });

  describe("withdraw", function () {
    it("should revert if note not existed.", async function () {
      const {
        root,
        nullifierHash,
        recipient,
        nullifier,
        secret,
        pathElements,
        pathIndices,
      } = await prepareWithdraw(123n, 456n, 789n, [
        await prepareDeposit(123n, 456n),
      ]);

      await expect(
        withdraw(
          root,
          nullifierHash,
          recipient,
          nullifier,
          secret,
          pathElements,
          pathIndices
        )
      ).to.revertedWith("Note not existed");
    });

    it("should revert if note already spent.", async function () {
      const nullifier = 123n;
      const secret = 456n;
      const recipient = 789n;

      const commitment = await prepareDeposit(nullifier, secret);
      await deposit(commitment, _denomination);

      const { root, nullifierHash, pathElements, pathIndices } =
        await prepareWithdraw(nullifier, secret, recipient, [commitment]);

      await withdraw(
        root,
        nullifierHash,
        recipient,
        nullifier,
        secret,
        pathElements,
        pathIndices
      );

      await expect(
        withdraw(
          root,
          nullifierHash,
          recipient,
          nullifier,
          secret,
          pathElements,
          pathIndices
        )
      ).to.revertedWith("Note already spent");
    });

    it("should revert if proof is invalid .", async function () {
      const nullifier = 123n;
      const secret = 456n;
      const recipient = 789n;

      const commitment = await prepareDeposit(nullifier, secret);
      await deposit(commitment, _denomination);

      const { root, nullifierHash, pathElements, pathIndices } =
        await prepareWithdraw(nullifier, secret, recipient, [commitment]);

      await expect(
        withdraw(
          root,
          nullifierHash,
          recipient,
          nullifier,
          secret,
          pathElements,
          pathIndices,
          true
        )
      ).to.revertedWith("Invalid proof");
    });

    it("should correctly withdraw and emit an event.", async function () {
      const nullifier = 123n;
      const secret = 456n;
      const recipient = 789n;

      const commitment = await prepareDeposit(nullifier, secret);
      await deposit(commitment, _denomination);

      const { root, nullifierHash, pathElements, pathIndices } =
        await prepareWithdraw(nullifier, secret, recipient, [commitment]);

      const vaultContractBalnceBefore =
        await _ownerAccount.provider!.getBalance(
          await _vaultContract.getAddress()
        );
      const recipientBalnceBefore = await _ownerAccount.provider!.getBalance(
        hex.from(recipient, 20)
      );

      await expect(
        withdraw(
          root,
          nullifierHash,
          recipient,
          nullifier,
          secret,
          pathElements,
          pathIndices
        )
      )
        .to.emit(_vaultContract, "Withdraw")
        .withArgs(
          nullifierHash,
          ethers.getAddress(hex.from(recipient, 20)),
          anyValue
        );

      const vaultContractBalnceAfter = await _ownerAccount.provider!.getBalance(
        await _vaultContract.getAddress()
      );
      const recipientBalnceAfter = await _ownerAccount.provider!.getBalance(
        hex.from(recipient, 20)
      );

      expect(vaultContractBalnceBefore - vaultContractBalnceAfter).to.equal(
        _denomination
      );
      expect(recipientBalnceAfter - recipientBalnceBefore).to.equal(
        _denomination
      );
    });

    it("should correctly withdraw and emit an event for multi (deposit + withdraw)s.", async function () {
      const commitments = [];

      for (let i = 0n; i < 3n; ++i) {
        const nullifier = 1230n + i;
        const secret = 4560n + i;
        const recipient = 7890n + i;

        const commitment = await prepareDeposit(nullifier, secret);
        await deposit(commitment, _denomination);
        commitments.push(commitment);

        const { root, nullifierHash, pathElements, pathIndices } =
          await prepareWithdraw(nullifier, secret, recipient, commitments);

        await expect(
          withdraw(
            root,
            nullifierHash,
            recipient,
            nullifier,
            secret,
            pathElements,
            pathIndices
          )
        )
          .to.emit(_vaultContract, "Withdraw")
          .withArgs(
            nullifierHash,
            ethers.getAddress(hex.from(recipient, 20)),
            anyValue
          );
      }
    });

    it("should correctly withdraw and emit an event for multi deposits and multi withdraws.", async function () {
      const commitments = [];

      for (let i = 0n; i < 3n; ++i) {
        const nullifier = 1230n + i;
        const secret = 4560n + i;

        const commitment = await prepareDeposit(nullifier, secret);
        await deposit(commitment, _denomination);
        commitments.push(commitment);
      }

      for (let i = 0n; i < 3n; ++i) {
        const nullifier = 1230n + i;
        const secret = 4560n + i;
        const recipient = 7890n + i;

        const { root, nullifierHash, pathElements, pathIndices } =
          await prepareWithdraw(
            nullifier,
            secret,
            recipient,
            commitments.slice(0, Number(i) + 1)
          );

        await expect(
          withdraw(
            root,
            nullifierHash,
            recipient,
            nullifier,
            secret,
            pathElements,
            pathIndices
          )
        )
          .to.emit(_vaultContract, "Withdraw")
          .withArgs(
            nullifierHash,
            ethers.getAddress(hex.from(recipient, 20)),
            anyValue
          );
      }
    });
  });
});

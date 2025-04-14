// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Groth16Verifier} from "./ZkVaultClassicVerifier.sol";
import {MerkleTree} from "./MerkleTree.sol";

/// @title ZkVaultClassic - A smart contract for deposit and withdrawal using zk-SNARK proofs
/// @notice This contract allows users to deposit a fixed amount of ETH anonymously
/// and withdraw later using a zero-knowledge proof.
contract ZkVaultClassic is ReentrancyGuard {
    // Verifier interface
    IVerifier private immutable _verifier;

    // Deposit denomination
    uint256 private immutable _denomination;

    // Use the MerkleTree library for the MerkleTree.Info type
    using MerkleTree for MerkleTree.Info;
    // Instance of the Merkle tree to manage commitments and roots
    MerkleTree.Info private _merkleTree;

    // Mapping to track the commitments that have been used, ensuring uniqueness
    mapping(uint256 => bool) private _commitments;
    // Mapping to track the commitments that have been used, ensuring uniqueness
    mapping(uint256 => bool) private _nullifierHashes;

    /// @dev Emitted when a deposit is made.
    /// @param commitment The Pedersen commitment hash of the deposit.
    /// @param leafIndex The index of the commitment leaf in the Merkle tree.
    /// @param timestamp The block timestamp when the deposit was made.
    event Deposit(
        uint256 indexed commitment,
        uint256 leafIndex,
        uint256 timestamp
    );

    /// @dev Emitted when a withdrawal is processed.
    /// @param nullifierHash The nullifier hash of the withdrawal.
    /// @param recipient The address of the user receiving the withdrawn ETH.
    /// @param timestamp The block timestamp when the withdrawal was made.
    event Withdraw(
        uint256 indexed nullifierHash,
        address indexed recipient,
        uint256 timestamp
    );

    /// @notice Initializes the vault with a verifier and fixed ETH denomination
    /// @param aAerifier The address of the zk-SNARK verifier contract
    /// @param aDenomination The fixed ETH amount for each deposit and withdrawal
    constructor(IVerifier aAerifier, uint256 aDenomination, uint256 aLevels) {
        _verifier = aAerifier;
        _denomination = aDenomination;
        _merkleTree.init(aLevels);
    }

    /// @notice Returns the fixed denomination required for deposit/withdraw
    /// @return The denomination value in wei
    function denomination() external view returns (uint256) {
        return _denomination;
    }

    /// @notice Returns the number of levels in the Merkle tree
    /// @return The number of levels in the Merkle tree
    function levels() external view returns (uint256) {
        return _merkleTree.levels;
    }

    /// @notice Returns the commitment at the given leaf index
    /// @param index The index of the leaf
    /// @return The commitment stored at the given index
    function getCommitment(uint256 index) external view returns (uint256) {
        return _merkleTree.leaves[index];
    }

    /// @notice Checks if a Merkle root is known in the Merkle tree
    /// @param root The root to check
    /// @return True if the root is known, false otherwise
    function isKnownRoot(uint256 root) external view returns (bool) {
        return _merkleTree.isKnownRoot(root);
    }

    /// @notice Allows users to deposit ETH with a unique Pedersen commitment
    /// @param commitment The Pedersen hash of the user's secret
    /// @dev The commitment must not have been used before.
    /// The sender must attach exactly `_denomination` ETH.
    function deposit(uint256 commitment) external payable nonReentrant {
        // Ensure the deposited amount matches the required denomination
        require(msg.value == _denomination, "Invalid deposit amount");

        // Ensure the commitment has not been used before
        require(!_commitments[commitment], "Commitment already used");

        // Insert the commitment as a leaf to merkle tree
        uint256 leafIndex = _merkleTree.insertLeaf(commitment);

        // Mark the commitment as used
        _commitments[commitment] = true;

        // Emit a Deposit event
        emit Deposit(commitment, leafIndex, block.timestamp);
    }

    /// @notice Withdraws ETH anonymously using a zk-SNARK proof
    /// @param pA zk-SNARK proof parameter A
    /// @param pB zk-SNARK proof parameter B
    /// @param pC zk-SNARK proof parameter C
    /// @param pubSignals The public inputs to the zk circuit:
    /// - pubSignals[0]: root
    /// - pubSignals[1]: nullifierHash
    /// - pubSignals[2]: recipient
    /// @dev The proof must be valid.
    ///   The root should exist in merkle tree.
    ///   The note should not have been spent.
    ///   The `_denomination` ETH is transferred to the recipient.
    function withdraw(
        uint[2] calldata pA,
        uint[2][2] calldata pB,
        uint[2] calldata pC,
        uint[3] calldata pubSignals
    ) external nonReentrant {
        // Retrieve the recipient address from the public signals
        address recipient = address(uint160(pubSignals[2]));

        // Retrieve the nullifierHash from the public signals,
        // and ensure it not spent
        uint256 nullifierHash = pubSignals[1];
        require(!_nullifierHashes[nullifierHash], "Note already spent");

        // Retrieve the root from the public signals
        // and ensure existing in merkle tree
        uint256 root = pubSignals[0];
        require(_merkleTree.isKnownRoot(root), "Note not existed");

        // Validate the zero-knowledge proof using the provided proof parameters
        bool valid = _verifier.verifyProof(pA, pB, pC, pubSignals);
        require(valid, "Invalid proof");

        // Mark the nullifier hash as spent
        _nullifierHashes[nullifierHash] = true;

        // Transfer the ETH to the recipient
        (bool sent, ) = recipient.call{value: _denomination}("");
        require(sent, "ETH transfer failed");

        // Emit a Withdraw event
        emit Withdraw(nullifierHash, recipient, block.timestamp);
    }

    /// @notice Fallback function blocks accidental ETH transfers
    /// @dev Users must use the `deposit()` function instead
    receive() external payable {
        revert("Use deposit function");
    }
}

/// @title IVerifier - Interface for zk-SNARK proof verifier
/// @dev Must return true if the proof and public signals are valid
interface IVerifier {
    /// @notice Verifies a zk-SNARK proof with public inputs
    /// @param pA Proof parameter A
    /// @param pB Proof parameter B
    /// @param pC Proof parameter C
    /// @param pubSignals The public input values used by the circuit
    /// @return Returns Returns true if the zk-SNARK proof is valid
    function verifyProof(
        uint[2] calldata pA,
        uint[2][2] calldata pB,
        uint[2] calldata pC,
        uint[3] calldata pubSignals
    ) external view returns (bool);
}

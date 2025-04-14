// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MerkleTree} from "./MerkleTree.sol";

/// @title A wrapper for the MiMC library, primarily used for unit testing.
/// @notice Primarily used for unit testing.
contract MerkleTreeWrapper {
    using MerkleTree for MerkleTree.Info;
    MerkleTree.Info private _merkleTree;

    /// @dev Emitted when a new leaf is inserted into the Merkle Tree
    /// @param index The index of the inserted leaf
    /// @param leaf The value of the inserted leaf
    event LeafInserted(uint256 indexed index, uint256 indexed leaf);

    /// @dev Constructor that initializes the Merkle Tree with the specified number of levels
    /// @param levels The number of levels in the Merkle Tree
    constructor(uint256 levels) {
        _merkleTree.init(levels);
    }

    /// @notice Inserts a new leaf into the Merkle tree and returns its index
    /// @param leaf The leaf value to be inserted
    /// @return The index of the inserted leaf
    function insertLeaf(uint256 leaf) external returns (uint256) {
        uint256 index = _merkleTree.insertLeaf(leaf);
        emit LeafInserted(index, leaf);
        return index;
    }

    /// @notice Checks if a given root is known
    /// @param root The root to check
    /// @return True if the root is known, false otherwise
    function isKnownRoot(uint256 root) external view returns (bool) {
        return _merkleTree.isKnownRoot(root);
    }
}

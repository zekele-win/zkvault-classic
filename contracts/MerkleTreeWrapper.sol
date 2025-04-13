// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MerkleTree} from "./MerkleTree.sol";

contract MerkleTreeWrapper {
    using MerkleTree for MerkleTree.Info;
    MerkleTree.Info private _merkleTree;

    event LeafInserted(uint256 indexed index, uint256 indexed leaf);

    constructor(uint256 levels, uint256 rootSize) {
        _merkleTree.init(levels, rootSize);
    }

    function insertLeaf(uint256 leaf) external returns (uint256) {
        uint256 index = _merkleTree.insertLeaf(leaf);
        emit LeafInserted(index, leaf);
        return index;
    }

    function isKnownRoot(uint256 root) external view returns (bool) {
        return _merkleTree.isKnownRoot(root);
    }

    function getRootSize() external view returns (uint256) {
        return _merkleTree.rootSize;
    }

    function getRoot(uint256 index) external view returns (uint256) {
        return _merkleTree.roots[index];
    }
}

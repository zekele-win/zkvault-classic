pragma circom 2.0.0;

include "./PedersenHasher.circom";
include "./MerkleTree.circom";

//
// Withdraw circuit (ZkVaultClassic)
// -----------------------------
// This circuit verifies that a user:
//  - Owns a valid deposit (nullifier + secret) included in the Merkle tree
//  - Has not yet used this deposit (via nullifierHash)
//  - Specifies a recipient address
//
// Public Inputs:
//  - root: Merkle root of known commitments (stored on-chain)
//  - nullifierHash: Hash of the nullifier to prevent double-spending
//  - recipient: Address to receive the withdrawn assets
//
// Private Inputs:
//  - nullifier: User’s unique identifier, used to prevent reuse
//  - secret: User’s secret, proving ownership of the deposit
//  - pathElements: Sibling hashes on the Merkle path
//  - pathIndices: Bitwise positions (left/right) on the Merkle path
//
template Withdraw(levels) {
    // Public input: Merkle root (on-chain known commitments)
    signal input root;
    // Public input: Used to track/spend only once
    signal input nullifierHash;
    // Public input: Where the withdrawn assets should go
    signal input recipient;

    // Private input: Must match nullifierHash and original commitment
    signal input nullifier;
    // Private input: Must match original commitment
    signal input secret;
    // Private input: Sibling nodes along Merkle path
    signal input pathElements[levels];
    // Private input: Direction bits (0: left, 1: right)
    signal input pathIndices[levels];

    // Enforce inputs are not zero
    assert(nullifier != 0);
    assert(secret != 0);
    assert(recipient != 0);

    // Compute commitment and nullifier hash
    // Ensure the provided public nullifierHash matches private input
    component hasher = PedersenHasher();
    hasher.nullifier <== nullifier;
    hasher.secret <== secret;
    hasher.nullifierHash === nullifierHash;

    // Recompute Merkle root from (commitment, path)
    // Ensure computed root matches public input
    component tree = MerkleTree(levels);
    tree.leaf <== hasher.commitment;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }
    tree.root === root;

    // Prevent recipient optimization elimination
    // This ensures the recipient signal is kept in the constraint system
    signal recipientSquare;
    recipientSquare <== recipient * recipient;
}

// Declare the main component and expose public signals
component main {public [root, nullifierHash, recipient]} = Withdraw(10);

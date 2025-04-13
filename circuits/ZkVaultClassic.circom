pragma circom 2.0.0;

include "./PedersenHasher.circom";
include "./MerkleTree.circom";

// Check if the nullifier and secret matches the given commitment 
// and the commitment is included in the merkle tree of deposits
// and pass through recipient
// 
// @param levels: merkle-tree levels
template Withdraw(levels) {
    // Public input: merkle-tree root
    signal input root;
    // Public input: hash of the nullifier
    signal input nullifierHash;
    // Public input: recipient address
    signal input recipient;

    // Private input: user’s nullifier to ensure uniqueness and prevent double usage
    signal input nullifier;
    // Private input: user’s secret, used to generate the commitment
    signal input secret;
    // Private input: path elements of merkle-tree
    signal input pathElements[levels];
    // Private input: path indices of merkle-tree
    signal input pathIndices[levels];

    // Output: recomputed root for consistency checking and on-chain verification
    signal output rootOut;
    // Output: recipient for passed through and on-chain verification
    signal output recipientOut;

    // Reject empty inputs
    assert(nullifier != 0);
    assert(secret != 0);
    assert(recipient != 0);

    // Compute pedersen hash from nullifier + secret to commitment
    component hasher = PedersenHasher();
    hasher.nullifier <== nullifier;
    hasher.secret <== secret;
    hasher.nullifierHash === nullifierHash;

    // Compute merkle-tree root from commitment as leaf and path elements and indices
    component tree = MerkleTree(levels);
    tree.leaf <== hasher.commitment;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }
    tree.root === root;

    // Output values for on-chain verification
    rootOut <== tree.root;
    recipientOut <== recipient;
}

// Declare the main circuit with public signals
component main {public [root, nullifierHash, recipient]} = Withdraw(10);

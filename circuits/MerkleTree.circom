pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

//
// A simple wrapper around MiMC Sponge hash with 2 inputs and 1 output.
//
template MiMCHash() {
    signal input left;
    signal input right;
    signal output hash;

    // Instantiate MiMC Sponge:
    // - 2 inputs (left and right nodes)
    // - 220 rounds (default)
    // - 1 output
    component hasher = MiMCSponge(2, 220, 1);

    hasher.ins[0] <== left;
    hasher.ins[1] <== right;

    // Set the key to zero (commonly used default)
    hasher.k <== 0;

    // Use the first output of the sponge as hash result
    hash <== hasher.outs[0];
}

//
// A binary mux component to order two nodes based on Merkle path index.
//
template DualMux() {
    // Two values to choose from
    signal input in[2];
    // Selector: 0 = keep order, 1 = swap order
    signal input s;
    // out[0] = left, out[1] = right
    signal output out[2];

    // Ensure selector is boolean: must be 0 or 1
    s * (1 - s) === 0;

    // out[0] = s == 0 ? in[0] : in[1]
    out[0] <== (in[1] - in[0])*s + in[0];
    // out[1] = s == 0 ? in[1] : in[0]
    out[1] <== (in[0] - in[1])*s + in[1];
}

//
// Merkle Tree inclusion proof circuit.
// Computes the Merkle root starting from a leaf and a Merkle path.
//
template MerkleTree(levels) {
    // Leaf node to start from
    signal input leaf;
    // Sibling hashes at each level
    signal input pathElements[levels];
    // 0 = sibling is on right, 1 = sibling is on left
    signal input pathIndices[levels];

    // Computed Merkle root
    signal output root;

    // DualMux components to order hash inputs
    component selectors[levels];
    // MiMCHash components per level
    component hashers[levels];

    for (var i = 0; i < levels; i++) {
        // Select the correct left/right input for hashing
        selectors[i] = DualMux();
        selectors[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];

        // Hash the two selected inputs to compute the parent node
        hashers[i] = MiMCHash();
        hashers[i].left <== selectors[i].out[0];
        hashers[i].right <== selectors[i].out[1];
    }

    // Final hash is the Merkle root
    root <== hashers[levels - 1].hash;
}

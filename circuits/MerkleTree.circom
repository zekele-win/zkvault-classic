pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/mimcsponge.circom";

// Simple two-input MiMC hash wrapper
template MiMCHash() {
    signal input left;
    signal input right;
    signal output hash;

    // Create a MiMC sponge instance with:
    //  - 2 inputs
    //  - 220 rounds
    //  - 1 output
    component hasher = MiMCSponge(2, 220, 1);

    hasher.ins[0] <== left;
    hasher.ins[1] <== right;
    hasher.k <== 0;

    // Output the first sponge result
    hash <== hasher.outs[0];
}

// Binary selector used in Merkle path selection
template DualMux() {
    // Two input values
    signal input in[2];
    // Selector (0 or 1)
    signal input s;
    // Two outputs (swapped or original)
    signal output out[2];

    // Enforce s to be boolean: must be 0 or 1
    s * (1 - s) === 0;

    // out[0] = s == 0 ? in[0] : in[1]
    out[0] <== (in[1] - in[0])*s + in[0];
    // out[1] = s == 0 ? in[1] : in[0]
    out[1] <== (in[0] - in[1])*s + in[1];
}

// Computes the Merkle root from a leaf with pathElements and pathIndices
template MerkleTree(levels) {
    // The leaf node to start from
    signal input leaf;
    // Merkle siblings (one per level)
    signal input pathElements[levels];
    // Binary index: 0 = left, 1 = right
    signal input pathIndices[levels];

    // Constructed Merkle root
    signal output root;

    // Used to arrange input order
    component selectors[levels];
    // Hash components per level
    component hashers[levels];

    for (var i = 0; i < levels; i++) {
        // Position the leaf/sibling correctly
        selectors[i] = DualMux();
        selectors[i].in[0] <== i == 0 ? leaf : hashers[i - 1].hash;
        selectors[i].in[1] <== pathElements[i];
        selectors[i].s <== pathIndices[i];

        // Hash the two selected values
        hashers[i] = MiMCHash();
        hashers[i].left <== selectors[i].out[0];
        hashers[i].right <== selectors[i].out[1];
    }

    // The final hash is the Merkle root
    root <== hashers[levels - 1].hash;
}

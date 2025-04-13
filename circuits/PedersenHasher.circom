pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/bitify.circom";
include "../node_modules/circomlib/circuits/pedersen.circom";

// Hash the nullifier to nullifierHash and nullifier + secret to commitment using Pedersen hash
template PedersenHasher() {
    // Input: user’s nullifier to ensure uniqueness and prevent double usage
    signal input nullifier;
    // Input: user’s secret, used to generate the commitment
    signal input secret;
    // Oututput: commitment computed from (nullifier + secret) represents a deposit
    signal output commitment;
    // Output: hash of the nullifier, used on-chain to detect and prevent double usage
    signal output nullifierHash;

    // Nullifier hash with 248-bit expectation
    component nullifierHasher = Pedersen(248);
    // (nullifier + commitment) hash with 496-bit expectation
    component commitmentHasher = Pedersen(496);
    // Nullifier bits with 248-bit array
    component nullifierBits = Num2Bits(248);
    // Secret bits with 248-bit array
    component secretBits = Num2Bits(248);

    // Convert nullifier and secret to bits and feed into Pedersen hasher
    nullifierBits.in <== nullifier;
    secretBits.in <== secret;
    for (var i = 0; i < 248; i++) {
        nullifierHasher.in[i] <== nullifierBits.out[i];
        commitmentHasher.in[i] <== nullifierBits.out[i];
        commitmentHasher.in[i + 248] <== secretBits.out[i];
    }

    // Use the first output of Pedersen hash
    commitment <== commitmentHasher.out[0];
    nullifierHash <== nullifierHasher.out[0];
}

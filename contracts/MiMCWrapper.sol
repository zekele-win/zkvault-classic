// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MiMC} from "./MiMC.sol";

/// @title A wrapper for the MiMC library, primarily used for unit testing.
/// @notice Primarily used for unit testing.
library MiMCWrapper {
    /// @notice Public hash function exposed for contracts
    /// @dev Performs 2 rounds of MiMC Sponge with left/right inputs
    /// @param left Left message input
    /// @param right Right message input
    /// @return The final hash output
    function hashLeftRight(
        uint256 left,
        uint256 right
    ) external pure returns (uint256) {
        return MiMC.hashLeftRight(left, right);
    }
}

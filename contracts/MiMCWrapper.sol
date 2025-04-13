// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MiMC} from "./MiMC.sol";

library MiMCWrapper {
    function hashLeftRight(
        uint256 left,
        uint256 right
    ) external pure returns (uint256) {
        return MiMC.hashLeftRight(left, right);
    }
}

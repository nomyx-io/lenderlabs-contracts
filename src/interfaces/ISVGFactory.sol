// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ISVGFactory {
    function templateAddress(string memory _name) external view returns (address);
}

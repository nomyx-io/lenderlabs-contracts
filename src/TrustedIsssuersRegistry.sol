// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IClaimIssuer } from "./interfaces/IClaimIssuer.sol";
import { ITrustedIssuersRegistry } from "./interfaces/ITrustedIssuersRegistry.sol";

contract TrustedIssuersRegistry is ITrustedIssuersRegistry {

    address public owner;
    IClaimIssuer[] public trustedIssuers;
    mapping(IClaimIssuer => uint[]) public trustedIssuerClaimTopics;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addTrustedIssuer(IClaimIssuer _trustedIssuer, uint[] calldata _claimTopics) external override onlyOwner {
        trustedIssuers.push(_trustedIssuer);
        trustedIssuerClaimTopics[_trustedIssuer] = _claimTopics;
        emit TrustedIssuerAdded(_trustedIssuer, _claimTopics);
    }

    function removeTrustedIssuer(IClaimIssuer _trustedIssuer) external override onlyOwner {
        for (uint i = 0; i < trustedIssuers.length; i++) {
            if (trustedIssuers[i] == _trustedIssuer) {
                trustedIssuers[i] = trustedIssuers[trustedIssuers.length - 1];
                trustedIssuers.pop();
                delete trustedIssuerClaimTopics[_trustedIssuer];
                emit TrustedIssuerRemoved(_trustedIssuer);
                break;
            }
        }
    }

    function updateIssuerClaimTopics(IClaimIssuer _trustedIssuer, uint[] calldata _claimTopics) external override onlyOwner {
        trustedIssuerClaimTopics[_trustedIssuer] = _claimTopics;
        emit ClaimTopicsUpdated(_trustedIssuer, _claimTopics);
    }

    function getTrustedIssuers() external view override returns (IClaimIssuer[] memory) {
        return trustedIssuers;
    }

    function isTrustedIssuer(address _issuer) external view override returns(bool) {
        for (uint i = 0; i < trustedIssuers.length; i++) {
            if (address(trustedIssuers[i]) == _issuer) {
                return true;
            }
        }
        return false;
    }

    function getTrustedIssuerClaimTopics(IClaimIssuer _trustedIssuer) external view override returns(uint[] memory) {
        return trustedIssuerClaimTopics[_trustedIssuer];
    }

    function hasClaimTopic(address _issuer, uint _claimTopic) external view override returns(bool) {
        uint[] memory claimTopics = trustedIssuerClaimTopics[IClaimIssuer(_issuer)];
        for (uint i = 0; i < claimTopics.length; i++) {
            if (claimTopics[i] == _claimTopic) {
                return true;
            }
        }
        return false;
    }

    function transferOwnershipOnIssuersRegistryContract(address _newOwner) external override onlyOwner {
        require(_newOwner != address(0), "New owner is the zero address");
        owner = _newOwner;
    }
}
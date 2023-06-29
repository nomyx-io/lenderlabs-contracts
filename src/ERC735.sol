// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import { IERC735 } from "./interfaces/IERC735.sol";
import { IIdentity } from "./interfaces/IIdentity.sol";
import { IClaimIssuer } from "./interfaces/IClaimIssuer.sol";
import { Claim } from "./interfaces/IClaimIssuer.sol";

import { ITrustedIssuersRegistry } from "./interfaces/ITrustedIssuersRegistry.sol";

/**
 * @title ERC735
 * @author Sebastian Schepis
 * @notice ERC735 implementation
 */
contract ERC735 is IERC735 {
    
    uint256 public claimCount;
    mapping(uint256 => Claim) public claims;
    mapping(bytes32 => uint256) public claimIdLookup;
    mapping(uint256 => bytes32[]) public claimsByTopic;

    address public issuerRegistry;
    constructor(address _issuerRegistry) {
        issuerRegistry = _issuerRegistry;
    }

    /// @notice get claim by claim id
    /// @param _claimId claim id
    /// @return topic claim topic
    function getClaim(bytes32 _claimId) external override view returns (uint256 topic, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri) {
        Claim memory claim = claims[claimIdLookup[_claimId]];
        return (claim.topic, claim.scheme, claim.issuer, claim.signature, claim.data, claim.uri);
    }

    /// @notice get claim by claim request id
    /// @param _topic claim request id
    /// @return claimIds claim topic
    function getClaimIdsByTopic(uint256 _topic) external view override returns (bytes32[] memory claimIds) {
        return claimsByTopic[_topic];
    }

    /// @notice add claim
    /// @param _topic claim topic
    /// @param _scheme claim scheme
    /// @param _issuer claim issuer
    /// @param _signature claim signature
    /// @param _data claim data
    /// @param _uri claim uri
    /// @return claimRequestId claim request id
    function addClaim(uint256 _topic, uint256 _scheme, address _issuer, bytes memory _signature, bytes memory _data, string memory _uri) external override returns (uint256 claimRequestId) {
        
        require(ITrustedIssuersRegistry(issuerRegistry).hasClaimTopic(_issuer, _topic), "Issuer is not trusted for this claim topic");

        claimCount += 1;
        claimRequestId = claimCount;
        bytes32 claimId = keccak256(abi.encodePacked(_issuer, _topic));
        claimIdLookup[claimId] = claimRequestId;

        Claim memory claim = Claim(_topic, _scheme, _issuer, _signature, _data, _uri, false);
        claims[claimRequestId] = claim;
        claimsByTopic[_topic].push(claimId);

        emit ClaimRequested(claimRequestId, _topic, _scheme, _issuer, _signature, _data, _uri);
        emit ClaimAdded(claimId, _topic, _scheme, _issuer, _signature, _data, _uri);
    }

    /// @notice change claim
    /// @param _claimId claim id
    /// @param _topic claim topic
    /// @param _scheme claim scheme
    /// @param _issuer claim issuer
    /// @param _signature claim signature
    /// @param _data claim data
    /// @param _uri claim uri
    function changeClaim(bytes32 _claimId, uint256 _topic, uint256 _scheme, address _issuer, bytes memory _signature, bytes memory _data, string memory _uri) external override returns (bool success) {
        
        require(ITrustedIssuersRegistry(issuerRegistry).hasClaimTopic(_issuer, _topic), "Issuer is not trusted for this claim topic");
        
        uint256 claimRequestId = claimIdLookup[_claimId];
        require(claimRequestId > 0, "Claim not found");
        
        Claim storage claim = claims[claimRequestId];
        require(claim.issuer == msg.sender, "Only claim issuer can change the claim");

        claim.topic = _topic;
        claim.scheme = _scheme;
        claim.signature = _signature;
        claim.data = _data;
        claim.uri = _uri;

        emit ClaimChanged(_claimId, _topic, _scheme, _issuer, _signature, _data, _uri);
        return true;
    }

    /// @notice remove claim
    /// @param _claimId claim id
    function removeClaim(bytes32 _claimId) external override returns (bool success) {

        require(claimIdLookup[_claimId] > 0, "Claim not found");

        uint256 claimRequestId = claimIdLookup[_claimId];
        require(claimRequestId > 0, "Claim not found");
        
        Claim storage claim = claims[claimRequestId];
        require(claim.issuer == msg.sender, "Only claim issuer can remove the claim");

        uint256 topic = claim.topic;
        uint256 lastIndex = claimsByTopic[topic].length - 1;
        for (uint256 i = 0; i <= lastIndex; i++) {
            if (claimsByTopic[topic][i] == _claimId) {
                claimsByTopic[topic][i] = claimsByTopic[topic][lastIndex];
                claimsByTopic[topic].pop();
                break;
            }
        }
        delete claimIdLookup[_claimId];
        delete claims[claimRequestId];

        emit ClaimRemoved(_claimId, topic, claim.scheme, claim.issuer, claim.signature, claim.data, claim.uri);
        return true;
    }
}

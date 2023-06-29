// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IERC735 {

    event ClaimRequested(uint256 indexed claimRequestId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed topic, uint256 scheme, address indexed issuer, bytes signature, bytes data, string uri);

    function getClaim(bytes32 _claimId) external returns(uint256 topic, uint256 scheme, address issuer, bytes memory signature, bytes memory data, string memory uri);
    function getClaimIdsByTopic(uint256 _topic) external returns(bytes32[] memory claimIds);
    function addClaim(uint256 _topic, uint256 _scheme, address _issuer, bytes memory _signature, bytes memory _data, string memory _uri) external returns (uint256 claimRequestId);
    function changeClaim(bytes32 _claimId, uint256 _topic, uint256 _scheme, address _issuer, bytes memory _signature, bytes memory _data, string memory _uri) external returns (bool success);
    function removeClaim(bytes32 _claimId) external returns (bool success);
}
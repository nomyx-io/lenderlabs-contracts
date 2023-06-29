// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IIdentity } from "./IIdentity.sol";
import { IIdentityRegistryStorage } from "./IIdentityRegistryStorage.sol";
import { ITrustedIssuersRegistry } from "./ITrustedIssuersRegistry.sol";
import { IClaimTopicsRegistry } from "./IClaimTopicsRegistry.sol";

interface IIdentityRegistry {

    // events
    event ClaimTopicsRegistrySet(address indexed claimTopicsRegistry);
    event IdentityStorageSet(address indexed identityStorage);
    event TrustedIssuersRegistrySet(address indexed trustedIssuersRegistry);
    event IdentityRegistered(address indexed investorAddress, IIdentity indexed identity);
    event IdentityRemoved(address indexed investorAddress, IIdentity indexed identity);
    event IdentityUpdated(IIdentity indexed oldIdentity, IIdentity indexed newIdentity);
    event CountryUpdated(address indexed investorAddress, uint16 indexed country);

    // functions
    // identity registry getters
    function identityStorage() external view returns (IIdentityRegistryStorage);
    function issuersRegistry() external view returns (ITrustedIssuersRegistry);
    function topicsRegistry() external view returns (IClaimTopicsRegistry);

    //identity registry setters
    function setIdentityRegistryStorage(address _identityRegistryStorage) external;
    function setClaimTopicsRegistry(address _claimTopicsRegistry) external;
    function setTrustedIssuersRegistry(address _trustedIssuersRegistry) external;

    // registry actions
    function registerIdentity(address _userAddress, IIdentity _identity, uint16 _country) external;
    function deleteIdentity(address _userAddress) external;
    function updateCountry(address _userAddress, uint16 _country) external;
    function updateIdentity(address _userAddress, IIdentity _identity) external;
    function batchRegisterIdentity(address[] calldata _userAddresses, IIdentity[] calldata _identities, uint16[] calldata _countries) external;

    // registry consultation
    function contains(address _userAddress) external view returns (bool);
    function isVerified(address _userAddress) external view returns (bool);
    function identity(address _userAddress) external view returns (IIdentity);
    function investorCountry(address _userAddress) external view returns (uint16);

    // roles setters
    function transferOwnershipOnIdentityRegistryContract(address _newOwner) external;
    function addAgentOnIdentityRegistryContract(address _agent) external;
    function removeAgentOnIdentityRegistryContract(address _agent) external;

    function getOnchainIDFromWallet(address _userAddress) external view returns (bytes32);
    function walletLinked(bytes32 _onchainID) external view returns (bool);
    function unlinkWallet(bytes32 _onchainID) external;
    function unlinkWalletAddress(address _walletAddress) external;
    function walletAddressLinked(address _walletAddress) external view returns (bool);

}
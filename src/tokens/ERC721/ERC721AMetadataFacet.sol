//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "../../libraries/LibDiamond.sol";
import "../../libraries/MetadataLib.sol";
import "../../libraries/AttributeLib.sol";
import "../../libraries/DiamondLib.sol";
import "../../libraries/ERC721ALib.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../../utilities/Modifiers.sol";

/* solhint-disable mark-callable-contracts */
/* solhint-disable var-name-mixedcase */
/* solhint-disable no-unused-vars */
/* solhint-disable two-lines-top-level-separator */
/* solhint-disable indent */


contract ERC721AMetadataFacet is Modifiers {

    using MetadataLib for MetadataContract;
    using ERC721ALib for ERC721AContract;
    using Strings for uint256;

    function setMetadata(MetadataContract memory _contract) external {

        LibDiamond.enforceIsContractOwner();
        MetadataLib.metadataStorage().metadata.setMetadata(_contract);
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() external view returns (string memory) {

        // solhint-disable-next-lsine
        return MetadataLib.metadataStorage().metadata.name();
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() external view returns (string memory) {

        // solhint-disable-next-line
        return MetadataLib.metadataStorage().metadata.symbol();
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function description() external view returns (string memory) {

        // solhint-disable-next-line
        return MetadataLib.metadataStorage().metadata.description();
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function image() external view returns (string memory) {

        // solhint-disable-next-line
        return MetadataLib.metadataStorage().metadata.image();
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function externalUri() external view returns (string memory) {

        // solhint-disable-next-line
        return MetadataLib.metadataStorage().metadata._externalUri;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function baseUri() external view returns (string memory) {

        // solhint-disable-next-line
        return MetadataLib.metadataStorage().metadata._externalUri;
    }
    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {

        ERC721AContract storage erc721Contract = ERC721ALib.erc721aStorage().erc721Contract;        
        if (!erc721Contract._exists(tokenId)) revert URIQueryForNonexistentToken();
        
        MetadataContract storage metadata = MetadataLib.metadataStorage().metadata;
        if(metadata._metadataSource == MetadataSource.EXTERNAL) {
            return string(
                abi.encodePacked(
                    metadata._baseUri, 
                    uint256(uint160(address(this))).toHexString(),
                    "/",
                    tokenId.toString())
                );
        } else {
            AttributeContract storage attributes = AttributeLib.attributeStorage().attributes;
            DiamondContract storage diamond = DiamondLib.diamondStorage().diamondContract;
            return metadata.tokenURI(diamond, attributes, tokenId);
        }
    }

    function setMetadataSource(MetadataSource _source) external {
        LibDiamond.enforceIsContractOwner();
        MetadataLib.metadataStorage().metadata._setMetadataSource(_source);
    }

    function setBaseUri(string memory _baseUri) external {
        LibDiamond.enforceIsContractOwner();
        MetadataLib.metadataStorage().metadata._setBaseURI(_baseUri);
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts().
     */
    function contractURI() external view returns (string memory) {

        MetadataContract storage metadata = MetadataLib.metadataStorage().metadata;
        Trait[] memory dum;
        if(metadata._metadataSource == MetadataSource.EXTERNAL) {
            return string(
                abi.encodePacked(
                    metadata._baseUri, 
                    uint256(uint160(address(this))).toHexString())
                );
        } else {
            (, string memory svg) = metadata.getContractImage();
            string memory json = Base64.encode(
                bytes(
                    metadata.getTokenMetadata(dum, svg)
                )
            );
            return string(abi.encodePacked("data:application/json;base64,", json));
        }

    }
}

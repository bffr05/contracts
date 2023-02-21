// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "../../../interfaces/base/IAble.sol";
import "../../base/access/Ownable.sol";
import "../../base/utils/Array.sol";
import "../../base/utils/Forwarder.sol";
import "../../base/utils/Array.sol";
import "../../base/access/Operatorable.sol"; 

abstract contract TokenPlaceStorage {

    struct TMInfo {
        address addr;
        uint40  features;
        uint56  chainId;
    }
    struct TMEquiv {
        address token;
        uint56  chainId;
        uint40  features;
    }

    mapping(address => TMInfo) internal _info; // token type and info

        mapping(address => string) internal _name; // token name
        mapping(address => string) internal _symbol; // token symbol
        mapping(address => address) internal _creatorOf; // token creator

        //TODO
        mapping(address => string) internal _image; // token image
        mapping(address => string) internal _uri; // token uri
        mapping(address => bool) internal _pause; // token pause

    address[] internal _machines; // list of all machines
    address[] internal _tokens;
    
    function TMInfoEncode(address addr_,uint40  features_,uint56  chainId_) public pure returns (uint256) {
        return TMInfoEncode(TMInfo({addr:addr_,features:features_,chainId:chainId_}));
    }
    function TMInfoEncode(TMInfo memory info_) public pure returns (uint256) {
        return uint160(info_.addr)*2**96|uint256(info_.features)*2**56|uint256(info_.chainId);
    }
    function TMInfoDecode(uint256 info_) public pure returns (TMInfo memory) {
        return TMInfo({addr:address(uint160(info_>>96)),features:uint40(info_>>56),chainId:uint56(info_)});
    }


    /*mapping(bytes32 => string) internal _images;
    string constant _defaultimage =
        "https://github.com/PatrickAlphaC/defi-stake-yield-brownie-freecode/blob/main/front_end/src/dapp.png?raw=true";
    string constant _imageeth =
        "https://raw.githubusercontent.com/PatrickAlphaC/defi-stake-yield-brownie-freecode/main/front_end/src/eth.png?raw=true";*/

}
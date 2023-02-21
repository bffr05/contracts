
// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "./aMERC1155.sol";

bytes32 constant kMERC1155 = keccak256("MERC1155");


contract MERC1155 is aMERC1155 {

    function declare( string memory symbol_, string memory name_) public returns (address) {
        address addr = get(_msgSender(),symbol_,name_);
        TokenPlace(location(kTokenPlace)).declare(addr,address(this),msg.sender,symbol_,name_);
        return addr;
    }
    function getSalt(address creator_,string memory symbol_, string memory name_) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(creator_,address(this),symbol_,name_));
    }

    function get(address creator_,string memory symbol_,string memory name_) public view virtual returns (address) {
        return Forwarder_Deployer(location(kForwarder_Deployer)).predict(address(this),getSalt(creator_,symbol_,name_));
    }    
    function get(string memory symbol_,string memory name_) external view returns (address) {
        return get(_msgSender(),symbol_,name_);
    }

    function deploy(address token_) public {
        require(token_.code.length == 0,                               "Machine contract exist");
        require(token_==Forwarder_Deployer(location(kForwarder_Deployer)).deploy(address(this),getSalt(TokenPlace(location(kTokenPlace)).creatorOf(token_),TokenPlace(location(kTokenPlace)).symbol(token_),TokenPlace(location(kTokenPlace)).name(token_))),                                       
            "Machine deploy addr mismatch");
    }


}
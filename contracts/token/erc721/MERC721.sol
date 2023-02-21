// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "./aMERC721Mint.sol";


contract MERC721 is aMERC721Mint {

    function declare( string memory symbol_, string memory name_) public returns (address) {
        address addr = get(msg.sender,symbol_,name_);
        assert(TokenPlace(location(kTokenPlace)).machine(addr)==address(0));
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
        return get(msg.sender,symbol_,name_);
    }

    function deploy(address token_) public {
        require(token_.code.length == 0,                               "Machine contract exist");
        require(token_==Forwarder_Deployer(location(kForwarder_Deployer)).deploy(address(this),getSalt(TokenPlace(location(kTokenPlace)).creatorOf(token_),TokenPlace(location(kTokenPlace)).symbol(token_),TokenPlace(location(kTokenPlace)).name(token_))),                                       
            "Machine deploy addr mismatch");
    }

}

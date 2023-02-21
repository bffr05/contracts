// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "../erc777/MERC777.sol";
import "./MEquiv.sol";

bytes32 constant kMEquivFT = keccak256("MEquivFT");

contract MEquivFT is LocationBase,aMERC777,MEquiv {

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual override (IERC165,aMERC777)
        returns (bool)
    {
        return
            super.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IEquiv).interfaceId ||
            interfaceId_ == type(IMEquiv).interfaceId;
    }
    
    function declare(uint56 remotechainId_,address remotetoken_,uint40 remotefeatures_, string memory remotesymbol_, string memory remotename_) public virtual override returns (address) {
        return super.declare(remotechainId_,remotetoken_,remotefeatures_|Token.FT,remotesymbol_,remotename_);
    }
    
}
// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "../erc721/aMERC721Mint.sol";
import "./MEquiv.sol";

bytes32 constant kMEquivNFT = keccak256("MEquivNFT");

contract MEquivNFT is LocationBase,aMERC721Mint,MEquiv {

    function supportsInterface(bytes4 interfaceId_)
        public
        view
        virtual override (IERC165,aMERC721)
        returns (bool)
    {
        return
            super.supportsInterface(interfaceId_) ||
            interfaceId_ == type(IEquiv).interfaceId ||
            interfaceId_ == type(IMEquiv).interfaceId;
    }
    function declare(uint56 remotechainId_,address remotetoken_,uint40 remotefeatures_, string memory remotesymbol_, string memory remotename_) public virtual override returns (address) {
        return super.declare(remotechainId_,remotetoken_,remotefeatures_|Token.NFT,remotesymbol_,remotename_);
    }

    /*function burn(address token, uint256 tokenId) public virtual override {
        super.burn(token,tokenId);
    }
    function burn(uint256 tokenId) public virtual override {
        super.burn(tokenId);
    }*/

}
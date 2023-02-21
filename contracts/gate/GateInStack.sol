// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "./IGate.sol";
import "./GateLib.sol";

import "../token/tokenplace/TokenPlaceLib.sol";
import "../token/equiv/MEquivFT.sol";
import "../token/equiv/MEquivNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../base/token/Token.sol";
import "../base/access/Operatorable.sol"; 


abstract contract GateInStack  {

    Stack internal stack;

    modifier onlyReentrancy() {
        if(!stack.reentrancy) revert Unauthorized(Unauthorized_Reason.onlyReentrancy);
        _;
    }

    function InItems() public view returns (StackItem[] memory ) {
        return stack.items;
    }
    function InChainId() public view returns (uint56) {
        return stack.chainId;
    }
    function InNonce() public view returns (uint256) {
        return stack.nonce;
    }
    function InSrc() public view returns (address) {
        return stack.src;
    }
    function InBalance(uint56 tokenChainId_, address token_,uint256 tokenId_) public view returns (uint256 ) {
        return GateLibTransfer.InBalance(stack,tokenChainId_, token_,tokenId_);
    }
    function InTransferFT(address to_, uint56 tokenChainId_, address token_, uint256 amount_) external onlyReentrancy {
        return GateLibTransfer.InTransferFT(stack,to_, tokenChainId_,token_,amount_);
    }
    function InTransferNFT(address to_, uint56 tokenChainId_, address token_, uint256 tokenId_) external onlyReentrancy {
        return GateLibTransfer.InTransferNFT(stack,to_, tokenChainId_,token_,tokenId_);
    }
    function InTransferMT(address to_, uint56 tokenChainId_, address token_, uint256[] calldata tokenId_, uint256[] calldata amount_) external onlyReentrancy {
        return GateLibTransfer.InTransferMT(stack,to_,tokenChainId_,token_,tokenId_,amount_);
    }

}

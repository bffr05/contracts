// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "./IGate.sol";
import "./GateInStack.sol";
import "./GateLib.sol";

import "../token/tokenplace/TokenPlaceLib.sol";
import "../token/equiv/MEquivFT.sol";
import "../token/equiv/MEquivNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../base/token/Token.sol";
import "../base/access/Operatorable.sol"; 


contract GateIn is OperatorableClient,IGateIn,GateInStack {

    mapping(uint256 => uint256) private nonces;

    function validIn(uint56 chainId_,uint256 nonce_) public view returns (bool) {
        return nonces[chainId_]<nonce_;
    }   


    modifier onlyThis() {
        if(address(this) != _msgSender()) revert Unauthorized(Unauthorized_Reason.onlyThis);
        _;
    }

    function InProcessMessage(GateMessage calldata msg_ ) external onlyThis returns (bytes memory returned,Message memory remainer ) {
        stack.chainId= msg_.chainId;
        stack.nonce= msg_.nonce;
        stack.src= msg_.src;

        returned= GateLibUtil.ProcessMessageStack(stack,msg_.message);
        remainer = GateLibUtil.stackToMessage(stack);
    }

    function In(GateMessage[] calldata msgs_) external onlyOperator(ownerOf()) { //
        for (uint i=0;i<msgs_.length;i++)
            _In(msgs_[i]);
    }

    function _In(GateMessage calldata msg_ ) internal  {
        if (!validIn(msg_.chainId,msg_.nonce))
            return;
        try GateIn(this).InProcessMessage(msg_) returns (bytes memory returned,Message memory remainer)
        {
            emit Inbound(msg_.chainId,msg_.nonce,msg_.src,remainer,true,returned);
        } catch (bytes memory reason) {
            emit Inbound(msg_.chainId,msg_.nonce,msg_.src,msg_.message,false,reason);
        }
        delete stack;
        nonces[msg_.chainId] = msg_.nonce;
        
    }



}
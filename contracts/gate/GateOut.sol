// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "./IGate.sol";
import "./GateLib.sol";
import "./GateLibTranscript.sol";

import "../token/tokenplace/TokenPlaceLib.sol";
import "../token/equiv/MEquivFT.sol";
import "../token/equiv/MEquivNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../base/token/Token.sol";
import "../base/access/Operatorable.sol"; 


contract GateOut is  OperatorableClient,IGateOut,IERC721Receiver,IERC1155Receiver {

    uint256 internal _base=1;
    uint256 internal _nonce=1;

    mapping(uint256 => bytes32) public mhashs;

    function base() public view returns (uint256) {
        return _base;
    }

    function nonce() public view virtual returns (uint256) {
        return _nonce;
    }
    function movebase() internal {
        for (uint256 i= _base;i<_nonce;i++)
        {
            if (validOut(i))
                return;
            _base=i+1;
        }   
    }


    function validOut(uint256 id_) public view returns (bool) {
        return mhashs[id_] != 0;
    }


    function Out(uint56  chainId, Message memory message) public payable returns (uint256 nonce_)
    {
        nonce_ = _nonce;
        mhashs[nonce_] = keccak256(abi.encode(_msgSender(),message));
        _nonce++;
        message = GateLibProcessMessage.ProcessMessageTransfer(_msgSender(),address(this),message);
        emit Outbound(chainId,nonce_,_msgSender(),message);
    }

    function OutCompleted(GateMessageCompleted[] calldata msgs_) external onlyOperator(ownerOf()) { // 
        for (uint i=0;i<msgs_.length;i++)
            _OutCompleted(msgs_[i]);
    }


    function _OutCompleted(GateMessageCompleted calldata msg_) internal {
        if (mhashs[msg_.nonce] == 0)
            return;
        GateLibProcessMessage.ProcessMessageTransfer(address(this),msg_.src,msg_.remainer);

        emit OutboundCompleted(msg_.nonce,msg_.result,msg_.returned,msg_.remainer);
        delete mhashs[msg_.nonce];

        if (msg_.nonce==_base)
            movebase();

        if (msg_.src.code.length != 0)
            try IGateReturn(msg_.src).GateOutReturned(msg_.nonce,msg_.result,msg_.returned,msg_.remainer) {} catch {}
    }


    function tokenOut(uint56 destChainId_, address token_,uint256 tokenId_,uint256 amount_) external payable  returns (uint256 nonce_) { //transaction(destChainId_)
        //(uint56 tchainId,address ttoken,uint40 tfeatures) = tokenTarget(token_); // 156260 - 152650

        Message[] memory messages_ = new Message[](2);
        messages_[0] = GateLibTranscript.StackToken(token_,tokenId_,amount_);
        messages_[1] = GateLibTranscript.Transfer(_msgSender());
        
        return Out(destChainId_,GateLibTranscript.Multi(messages_));
    }
    function test(uint56 destChainId_) external payable  returns (uint256 nonce_) { //transaction(destChainId_)
        //(uint56 tchainId,address ttoken,uint40 tfeatures) = tokenTarget(token_); // 156260 - 152650

        Message[] memory messages_ = new Message[](0);
        return Out(destChainId_,GateLibTranscript.Multi(messages_));
    }



    function onERC721Received(address operator, address , uint256 , bytes calldata  ) external view returns (bytes4) {
        return operator==address(this) ? IERC721Receiver.onERC721Received.selector : bytes4(0);
        //return IERC721Receiver.onERC721Received.selector;
    }

    function onERC1155Received(address operator, address , uint256 , uint256 , bytes calldata  ) external view returns (bytes4) {
        return operator==address(this) ? IERC1155Receiver.onERC1155Received.selector : bytes4(0);
        //return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address operator, address , uint256[] calldata , uint256[] calldata , bytes calldata ) external view returns (bytes4) {
        return operator==address(this) ? IERC1155Receiver.onERC1155BatchReceived.selector : bytes4(0);
        //return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

}

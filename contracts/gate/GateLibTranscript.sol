// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "./GateTypes.sol";
import "../base/utils/Array.sol";

/*
import "../token/tokenplace/TokenPlaceLib.sol";
import "../token/equiv/MEquivFT.sol";
import "../token/equiv/MEquivNFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../base/token/Token.sol";
import "../base/access/Operatorable.sol"; 
*/

library GateLibTranscript {
    function decodeFT(bytes memory in_) public pure returns (MessageFT memory) {
        return abi.decode((in_),(MessageFT));
    } 
    function encodeFT(MessageFT memory in_) public pure returns (bytes memory) {
        return (abi.encode(in_));
    } 

    function encodeFT(uint56 tokenChainId_,address token_,uint256 amount_) public pure returns (bytes memory) {
        return encodeFT(MessageFT({tokenChainId:tokenChainId_,token:token_,amount:amount_}));
    } 

    function decodeAddress(bytes memory in_) public pure returns (MessageAddress memory) {
        return abi.decode((in_),(MessageAddress));
    } 
    function encodeAddress(MessageAddress memory in_) public pure returns (bytes memory) {
        return (abi.encode(in_));
    } 
    function decodeHash(bytes memory in_) public pure returns (MessageHash memory) {
        return abi.decode((in_),(MessageHash));
    } 
    function encodeHash(MessageHash memory in_) public pure returns (bytes memory) {
        return (abi.encode(in_));
    } 
    function decodeMultiHash(bytes memory in_) public pure returns (MessageMultiHash memory) {
        return abi.decode((in_),(MessageMultiHash));
    } 
    function encodeMultiHash(MessageMultiHash memory in_) public pure returns (bytes memory) {
        return (abi.encode(in_));
    } 


    function decodeNFT(bytes memory in_) public pure returns (MessageNFT memory) {
        return abi.decode((in_),(MessageNFT));
    } 
    function encodeNFT(MessageNFT memory in_) public pure returns (bytes memory) {
        return (abi.encode(in_));
    } 
    function encodeNFT(uint56 tokenChainId_,address token_,uint256 tokenId_) public pure returns (bytes memory) {
        return encodeNFT(MessageNFT({tokenChainId:tokenChainId_,token:token_,tokenId:tokenId_}));
    } 
    function decodeMT(bytes memory in_) public pure returns (MessageMT memory) {
        return abi.decode((in_),(MessageMT));
    } 
    function encodeMT(MessageMT memory in_) public pure returns (bytes memory) {
        return (abi.encode(in_));
    } 
    function encodeMT(uint56 tokenChainId_,address token_,uint256[] memory tokenId_,uint256[] memory amount_) public pure returns (bytes memory) {
        return encodeMT(MessageMT({tokenChainId:tokenChainId_,token:token_,tokenId:tokenId_,amount:amount_}));
    } 

    function decodeMulti(bytes memory in_) public pure returns (Message[] memory) {
        return abi.decode(in_,(Message[]));
    } 
    function encodeMulti(Message[] memory in_) public pure returns (bytes memory) {
        return abi.encode(in_);
    } 
    function Multi(Message[] memory messages_) public pure returns (Message memory message)  {

        if (messages_.length==1)
            message = messages_[0];
        else
            message = Message({ mType: MessageType.Multi,message: encodeMulti(messages_)});
    }
    function StackToken(address token_,uint256 tokenId_,uint256 amount_) public pure returns (Message memory message) {
            message = Message({ mType: MessageType.MT,message: encodeMT(MessageMT({tokenChainId:0,token:token_,tokenId:Array.munique(tokenId_),amount:Array.munique(amount_)}))});
    }     
    function StackMToken(address token_,uint256[] memory tokenId_,uint256[] memory amount_) public pure returns (Message memory message) {
            message = Message({ mType: MessageType.MT,message: encodeMT(MessageMT({tokenChainId:0,token:token_,tokenId:tokenId_,amount:amount_}))});
    }     
    function Transfer(address addr_) public pure returns (Message memory message)  {
        message = Message({ mType: MessageType.Transfer,message: encodeAddress(MessageAddress({addr:addr_}))});
    }     
    function Hash(bytes32 hash_) public pure returns (Message memory message)  {
        message = Message({ mType: MessageType.Hash,message: encodeHash(MessageHash({h:hash_}))});
    }     
    function Address(address addr_) public pure returns (Message memory message)  {
        message = Message({ mType: MessageType.Address,message: encodeAddress(MessageAddress({addr:addr_}))});
    }     
    function CodeHash(bytes32 hash_) public pure returns (Message memory message)  {
        message = Message({ mType: MessageType.CodeHash,message: encodeHash(MessageHash({h:hash_}))});
    }     
    function MultiCodeHash(bytes32[] memory hashs_) public pure returns (Message memory message)  {
        message = Message({ mType: MessageType.MultiCodeHash,message: encodeMultiHash(MessageMultiHash({h:hashs_}))});
    }     

    function Balance() public pure returns (Message memory message)  {
        message = Message({ mType: MessageType.Balance,message: ""});
    }     
    function EOA() public pure returns (Message memory message)  {
        message = Message({ mType: MessageType.EOA,message: ""});
    }     
    function Call(bytes memory call_) public pure returns (Message memory message)  {
        message = Message({ mType: MessageType.Call,message: call_});
    }     


}

// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

/*
enum TokenType {
    FT,
    NFT,
    MT
}
*/
/*
error Unauthorized();
error Unauthorized_onlyThis();
error Unauthorized_onlyReentrancy();
error Unsupported();
error Unsupported_TokenType();
error Unsupported_Message();

error InvalidAmout();
*/
error GateOut_Token_TypeMismatch();

error GateIn_Address_LocationHashNotFound();
error GateIn_Address_BalanceInactive();
error GateIn_Address_EOA();
error GateIn_Address_CA();
error GateIn_Address_CodeHashUnknown();
error GateIn_Address_Undefined();
error GateIn_Call_Errored();


enum MessageType {
    NONE,
    Multi,
    FT,
    NFT,
    MT,
    Transfer,
    Hash,
    Address,
    Balance,
    EOA,
    CA,
    CodeHash,
    MultiCodeHash,
    Call
}

struct GateMessage {
    uint56              chainId;
    uint256             nonce;
    address             src;
    Message             message;
}
struct GateMessageCompleted {
    uint256             nonce;
    address             src;
    Message             remainer;
    bool                result; 
    bytes               returned;
}

struct Message {
    MessageType         mType;    
    bytes               message;
}

struct MessageAddress {
    address             addr;           
}
struct MessageMultiHash {
    bytes32[]           h;           
}
struct MessageHash {
    bytes32             h;           
}

struct MessageFT {
    uint56              tokenChainId;   
    address             token;  
    uint256             amount;
}
struct MessageNFT {
    uint56              tokenChainId;   
    address             token;  
    uint256             tokenId;
}

struct MessageMT {
    uint56              tokenChainId;   
    address             token;  
    uint256[]           tokenId;
    uint256[]           amount;
}

struct StackItem {
    uint40              tFeatures;
    uint56              tokenChainId;   
    address             token;  
    uint256[]           tokenId;
    uint256[]           amount;
}

struct Stack {
    uint56              chainId;
    uint256             nonce;
    address             src;
    StackItem[]         items;
    address             calladdress;


    bool                reentrancy;
}
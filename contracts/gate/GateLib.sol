// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "./GateTypes.sol";
import "./Gate.sol";
import "./GateLibTranscript.sol";
import "../base/utils/Array.sol";
import "../base/utils/Error.sol";
import "../base/token/Token.sol";
import "../token/tokenplace/TokenPlaceLib.sol";
import "../token/equiv/MEquivFT.sol";
import "../token/equiv/MEquivNFT.sol";

library GateLibTransfer {

    function transfer(address  src_,address  dest_,uint40 tFeatures_, uint56 tokenChainId_,address token_,uint256[] memory tokenId_,uint256[] memory amount_) public {
        assert(src_!=dest_);
        Gate gate = Gate(address(this)); 
        if (tokenChainId_== block.chainid||tokenChainId_==0) {
            TokenPlace tokenPlace = TokenPlace(gate.location(kTokenPlace));
            TokenPlaceLib.transferFrom( tokenPlace, src_,dest_,token_,tokenId_,amount_,"");
            return;
        }
        if (Token.ft(tFeatures_))
        {
            MEquivFT mEquivFT = MEquivFT(LocationBase(address(this)).location(kMEquivFT));
            address token = mEquivFT.declare(tokenChainId_,token_);
            if (src_==address(this)) {
                for (uint j=0;j<amount_.length;j++)
                   mEquivFT.mint(token,dest_,amount_[j],"","");
            }
            else if (dest_ == address(this)) 
                for (uint j=0;j<amount_.length;j++) 
                    mEquivFT.burn(token,src_,amount_[j],"","");
            else 
                revert Unsupported(Unsupported_Reason.Unkwown);
        }
        else if (Token.nft(tFeatures_))
        {
            MEquivNFT mEquivNFT = MEquivNFT(LocationBase(address(this)).location(kMEquivNFT));
            address token = mEquivNFT.declare(tokenChainId_,token_);
            if (src_==address(this)) {
                for (uint j=0;j<tokenId_.length;j++) 
                    mEquivNFT.safeMint(token,dest_,tokenId_[j],"");
            }
            else if (dest_ == address(this)) 
                for (uint j=0;j<amount_.length;j++) 
                    mEquivNFT.burn(token,src_,tokenId_[j]);
            else 
                revert Unsupported(Unsupported_Reason.Unkwown);
        }
        else
            revert Unsupported(Unsupported_Reason.TokenType);
    }

    function InBalance(Stack storage stack_,uint56 tokenChainId_, address token_,uint256 tokenId_) public view returns (uint256 ) {
        for (uint i=0;i<stack_.items.length;i++){
            if (Token.ft(stack_.items[i].tFeatures) && tokenChainId_==stack_.items[i].tokenChainId && token_==stack_.items[i].token) 
                return stack_.items[i].amount[0];
            
            if (Token.nft(stack_.items[i].tFeatures) && tokenChainId_==stack_.items[i].tokenChainId && token_==stack_.items[i].token && tokenId_==stack_.items[i].tokenId[0])
                return stack_.items[i].amount[0];
            
            if (Token.mt(stack_.items[i].tFeatures) && tokenChainId_==stack_.items[i].tokenChainId && token_==stack_.items[i].token) {
                for (uint j=0;j<stack_.items[i].tokenId.length;j++)
                    if (stack_.items[i].tokenId[j]==tokenId_)
                        return stack_.items[i].amount[j];
            }
            
        }
        return 0;


    }

    function InTransferFT(Stack storage stack_,address to_, uint56 tokenChainId_, address token_, uint256 amount_) public  {
        uint len = stack_.items.length;
        for (uint i=0;i<len;i++){
            if (Token.ft(stack_.items[i].tFeatures) && tokenChainId_==stack_.items[i].tokenChainId && token_==stack_.items[i].token) {
                if ( stack_.items[i].amount[0]< amount_) revert BalanceExceeded();
                stack_.items[i].amount[0]-=amount_;
                if (stack_.items[i].amount[0]==0) {
                    if (i<len-1)
                        stack_.items[i] = stack_.items[len-1];
                    stack_.items.pop();
                }
                transfer(address(this),to_,stack_.items[i].tFeatures,tokenChainId_,token_,Array.munique(uint256(0)),Array.munique(amount_));                
                return;
            }
        }
        revert BalanceExceeded();
    }
    function InTransferNFT(Stack storage stack_,address to_, uint56 tokenChainId_, address token_, uint256 tokenId_) public  {
        uint len = stack_.items.length;
        for (uint i=0;i<len;i++){
            if (Token.nft(stack_.items[i].tFeatures) && tokenChainId_==stack_.items[i].tokenChainId && token_==stack_.items[i].token && tokenId_==stack_.items[i].tokenId[0]) {
                if (i<len-1)
                    stack_.items[i] = stack_.items[len-1];
                stack_.items.pop();
                transfer(address(this),to_,stack_.items[i].tFeatures,tokenChainId_,token_,Array.munique(tokenId_),Array.munique(uint256(1)));                
                return;
            }
        }
        revert BalanceExceeded();
    }

    function InTransferMT(Stack storage stack_,address to_, uint56 tokenChainId_, address token_, uint256[] calldata tokenId_, uint256[] calldata amount_) public {
        uint len = stack_.items.length;
        for (uint i=0;i<len;i++){
            if (Token.mt(stack_.items[i].tFeatures) && tokenChainId_==stack_.items[i].tokenChainId && token_==stack_.items[i].token) {
                uint lentokenId = stack_.items[i].tokenId.length;
                for (uint t=0;t<tokenId_.length;t++)
                    for (uint j=0;j<lentokenId;j++){
                        if (stack_.items[i].tokenId[j]==tokenId_[t]) {
                            if ( stack_.items[i].amount[j]< amount_[t]) revert BalanceExceeded();
                            stack_.items[i].amount[j]-=amount_[t];
                        } 
                }
                // removing stack_ item mt tokenId empty
                for (uint j=0;j<lentokenId;){
                    if (stack_.items[i].amount[j]==0) {
                        if (j<lentokenId-1) {
                            stack_.items[i].tokenId[j] = stack_.items[i].tokenId[lentokenId-1];
                            stack_.items[i].amount[j] = stack_.items[i].amount[lentokenId-1];
                        }
                        stack_.items[i].tokenId.pop();
                        stack_.items[i].amount.pop();
                        lentokenId--;
                        continue;
                    }
                    j++;
                }
                if (lentokenId==0)
                {
                    if (i<len-1)
                        stack_.items[i] = stack_.items[len-1];
                    stack_.items.pop();
                }
                transfer(address(this),to_,stack_.items[i].tFeatures,tokenChainId_,token_,tokenId_,amount_);                
                return;
            }
        }
        revert BalanceExceeded();
    }    
}

library GateLibUtil {

    function stackToMessage(Stack storage stack_) public view returns (Message memory) {
        Message[] memory messages_ = new Message[](stack_.items.length);
        for (uint i=0;i<stack_.items.length;i++)
        {
            if (Token.ft(stack_.items[i].tFeatures)) 
                messages_[i] = Message({ mType: MessageType.FT,message: GateLibTranscript.encodeFT(uint56(stack_.items[i].tokenChainId==0?block.chainid:stack_.items[i].tokenChainId),stack_.items[i].token,stack_.items[i].amount[0])});
            else if (Token.nft(stack_.items[i].tFeatures))
                messages_[i] = Message({ mType: MessageType.NFT,message: GateLibTranscript.encodeNFT(uint56(stack_.items[i].tokenChainId==0?block.chainid:stack_.items[i].tokenChainId),stack_.items[i].token,stack_.items[i].tokenId[0])});
            else if (Token.mt(stack_.items[i].tFeatures))
                messages_[i] = Message({ mType: MessageType.MT,message: GateLibTranscript.encodeMT(uint56(stack_.items[i].tokenChainId==0?block.chainid:stack_.items[i].tokenChainId),stack_.items[i].token,stack_.items[i].tokenId,stack_.items[i].amount)});
            else 
                revert Unsupported(Unsupported_Reason.TokenType);
        }
        return GateLibTranscript.Multi(messages_);
    }


    function equiv(address token_) public returns (uint56 tchainId_,address ttoken_,uint40 tfeatures_)
    {
        Gate gate = Gate(address(this)); 
        TokenPlace tokenPlace = TokenPlace(gate.location(kTokenPlace));

        tchainId_ = uint56(block.chainid);
        ttoken_ = token_;
        tfeatures_ = tokenPlace.features(token_);
        if (tokenPlace.creatorOf(token_)==address(this))
            (tchainId_,ttoken_,tfeatures_) = IEquiv(token_).equiv();
    }

    function ProcessMessageStack(Stack storage stack_,Message memory message_) public returns (bytes memory returned)
    {
        if (message_.mType==MessageType.Multi) {
            Message[] memory multi = GateLibTranscript.decodeMulti(message_.message);
            for (uint i=0;i<multi.length;i++)
                ProcessMessageStack(stack_,multi[i]);
        }
        else if (message_.mType==MessageType.FT) {
            MessageFT memory message = GateLibTranscript.decodeFT(message_.message);
            if (message.tokenChainId==block.chainid)
                message.tokenChainId = 0;
            stack_.items.push(StackItem({tFeatures:Token.FT,tokenChainId:message.tokenChainId==block.chainid?0:message.tokenChainId,token:message.token,tokenId:Array.munique(uint256(0)),amount:Array.munique(message.amount)}));
        }
        else if (message_.mType==MessageType.NFT) {
            MessageNFT memory message = GateLibTranscript.decodeNFT(message_.message);
            if (message.tokenChainId==block.chainid)
                message.tokenChainId = 0;
            stack_.items.push(StackItem({tFeatures:Token.NFT,tokenChainId:message.tokenChainId==block.chainid?0:message.tokenChainId,token:message.token,tokenId:Array.munique(message.tokenId),amount:Array.munique(uint256(1))}));
        }
        else if (message_.mType==MessageType.MT) {
            MessageMT memory message = GateLibTranscript.decodeMT(message_.message);
            if (message.tokenChainId==block.chainid)
                message.tokenChainId = 0;
            stack_.items.push(StackItem({tFeatures:Token.MT,tokenChainId:message.tokenChainId==block.chainid?0:message.tokenChainId,token:message.token,tokenId:message.tokenId,amount:message.amount}));
        }
        else if (message_.mType==MessageType.Hash) {
            MessageHash memory message = GateLibTranscript.decodeHash(message_.message);
            stack_.calladdress = LocationBase(address(this)).location(message.h);
            if(stack_.calladdress == address(0)) revert GateIn_Address_LocationHashNotFound();
        }
        else if (message_.mType==MessageType.Address) {
            MessageAddress memory message = GateLibTranscript.decodeAddress(message_.message);
            stack_.calladdress = message.addr;
        }
        else if (message_.mType==MessageType.Balance) {
            if (stack_.calladdress.balance == 0) revert GateIn_Address_BalanceInactive();
        }
        else if (message_.mType==MessageType.EOA) {
            if (stack_.calladdress.code.length != 0) revert GateIn_Address_CA();
        }
        else if (message_.mType==MessageType.CA) {
            if (stack_.calladdress.code.length != 0) revert GateIn_Address_EOA();
        }
        else if (message_.mType==MessageType.CodeHash) {
            MessageHash memory message = GateLibTranscript.decodeHash(message_.message);
            if(stack_.calladdress.codehash != message.h) revert GateIn_Address_CodeHashUnknown();
        }
        else if (message_.mType==MessageType.MultiCodeHash) {
            MessageMultiHash memory message = GateLibTranscript.decodeMultiHash(message_.message);
            bool found = false;
            for (uint i=0;i<message.h.length;i++)
                if (stack_.calladdress.codehash==message.h[i])
                    found = true;
            if (!found) revert GateIn_Address_CodeHashUnknown();
        }
        else if (message_.mType==MessageType.Transfer) {
            MessageAddress memory message = GateLibTranscript.decodeAddress(message_.message);
            if (message.addr!=address(0))
                stack_.calladdress = message.addr;
            if (stack_.calladdress==address(0)) revert GateIn_Address_Undefined();
            for (uint i=0;i<stack_.items.length;i++)
                GateLibTransfer.transfer(address(this),stack_.calladdress,stack_.items[i].tFeatures, stack_.items[i].tokenChainId,stack_.items[i].token,stack_.items[i].tokenId,stack_.items[i].amount);
            delete stack_.items;
        }
        else if (message_.mType==MessageType.Call) {
            bool _result;
            stack_.reentrancy = true;
            (_result, returned) = stack_.calladdress.call( Tools.addTailAddress(message_.message,stack_.src));
            if (!_result)
                revert GateIn_Call_Errored();
            stack_.reentrancy = false;
        }
        else
            revert Unsupported(Unsupported_Reason.MessageType);
    }
}
library GateLibProcessMessage {
    function ProcessMessageTransfer(address  src_,address  dest_,Message memory message_) public returns (Message memory) {
        assert(src_!=dest_);

        if (message_.mType==MessageType.Multi) {
            Message[] memory multi = GateLibTranscript.decodeMulti(message_.message);
            for (uint i=0;i<multi.length;i++)
                multi[i] = ProcessMessageTransfer(src_,dest_,multi[i]);
            // Out => dest_==address(this)  
            // OutComplete => dest_!=address(this)  
            if (dest_==address(this))  
                message_.message = GateLibTranscript.encodeMulti(multi);
        }
        else if (message_.mType==MessageType.FT) {
            MessageFT memory message = GateLibTranscript.decodeFT(message_.message);
            // Out => dest_==address(this)  
            // OutComplete => dest_!=address(this)  
            if (dest_==address(this)) {
                // If we are going Out, this shouldnt be possible
                revert GateOut_Token_TypeMismatch();
                /*
                uint40 tfeatures_;
                (message.tokenChainId,message.token,tfeatures_) = _equiv(message.token);
                if (!Token.ft(tfeatures_)) revert GateOut_Token_TypeMismatch();
                message_.message = encodeFT(message);
                */
            }
            GateLibTransfer.transfer(src_,dest_,Token.FT,message.tokenChainId,message.token,Array.munique(uint256(0)),Array.munique(message.amount));
        }
        else if (message_.mType==MessageType.NFT) {
            MessageNFT memory message = GateLibTranscript.decodeNFT(message_.message);
            // Out => dest_==address(this)  
            // OutComplete => dest_!=address(this)  
            if (dest_==address(this)) {
                // If we are going Out, this shouldnt be possible
                revert GateOut_Token_TypeMismatch();
                /*
                uint40 tfeatures_;
                (message.tokenChainId,message.token,tfeatures_) = _equiv(message.token);
                if (!Token.nft(tfeatures_)) revert GateOut_Token_TypeMismatch();
                message_.message = encodeNFT(message);
                */
            }
            GateLibTransfer.transfer(src_,dest_,Token.NFT,message.tokenChainId,message.token,Array.munique(message.tokenId),Array.munique(uint256(1)));
        }
        else if (message_.mType==MessageType.MT) {
            MessageMT memory message = GateLibTranscript.decodeMT(message_.message);
            // Out => dest_==address(this)  
            // OutComplete => dest_!=address(this)  
            if (dest_==address(this)) {
                if (message.tokenChainId==0)
                    message.tokenChainId=uint56(block.chainid);
                // If we are going Out, all tokens are MT
                // We need to reprocess it to equiv and FT,NFT,MT

                // We try to check if token is Gate Equiv
                uint40 tfeatures_;
                (message.tokenChainId,message.token,tfeatures_) = GateLibUtil.equiv(message.token);
                // if this is Gate Equiv :  tokenChainId is remote, token is remote and feature should be FT NFT MT
                // if this is not Gate Equiv : tokenChainId is block.chainid, token is unchanged, feature is TokenPlace feature scan

                if (Token.mt(tfeatures_)) {
                    // if token is MT, we repack message and we transfer 
                    message_.message = GateLibTranscript.encodeMT(message);
                    GateLibTransfer.transfer(src_,dest_,Token.MT,message.tokenChainId,message.token,message.tokenId,message.amount);
                }
                else if (Token.ft(tfeatures_)) {
                    // PARANOIA multi FT, should only be one FT
                    uint256 amount;
                    for (uint i=0;i<message.amount.length;i++)
                        amount+=message.amount[i];
                    // if token is FT, we overwrite message and we transfer 
                    message_ = Message({mType:MessageType.FT,message:GateLibTranscript.encodeFT(message.tokenChainId,message.token,amount)});
                    GateLibTransfer.transfer(src_,dest_,Token.FT,message.tokenChainId,message.token,Array.munique(uint256(0)),Array.munique(amount));
                }
                else if (Token.nft(tfeatures_)) {
                    // PARANOIA multi NFT, should only be one NFT
                    Message[] memory messagesnft = new Message[](message.tokenId.length);
                    for (uint i=0;i<message.tokenId.length;i++)
                        messagesnft[i] = Message({ mType: MessageType.NFT,message: GateLibTranscript.encodeNFT(MessageNFT({tokenChainId:message.tokenChainId,token:message.token,tokenId:message.tokenId[i]}))});
                    // if token is NFT, we overwrite message and we transfer 
                    if (messagesnft.length==1) message_ = messagesnft[0];
                    else message_ = GateLibTranscript.Multi(messagesnft);
                    GateLibTransfer.transfer(src_,dest_,Token.NFT,message.tokenChainId,message.token,message.tokenId,message.amount);
                }
            }
            else 
                GateLibTransfer.transfer(src_,dest_,Token.MT,message.tokenChainId,message.token,message.tokenId,message.amount);
        }
        return message_;
    }    

}
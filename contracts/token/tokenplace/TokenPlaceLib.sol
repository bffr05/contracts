// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "../../base/token/Token.sol";
import "./TokenPlace.sol";
import "../erc721/IMERC721.sol";
import "../erc777/IMERC777.sol";
import "../erc1155/IMERC1155.sol";

library TokenPlaceLib {


    /*function transferFrom(
        TokenPlace tokenplace_,
        address from_,
        address to_,
        address token_,
        uint256 id_,
        uint256 amount_,
        bytes memory data_
    ) internal {
        uint40 features_ = tokenplace_.features(token_);
        require(
            Token.transferable(token_, features_, id_),
            "TokenPlaceLib: transferFrom Token must be transferable"
        );
        uint40 t = Token.typeOf(features_);
        if (t == Token.TypeCoin) 
        {
            if (from_==address(this))
                payable(to_).transfer(amount_);
            else if (to_==address(this)) 
                require(msg.sender==from_,"transferFrom: Invalid from for coin");
            else require(false, "transferFrom: Invalid operation for Coin");
        }
        else if ((t == Token.TypeERC20) || (t == Token.TypeERC777))
        {
            if (tokenplace_.machine(token_)!=address(0))
                IMERC777(tokenplace_.machine(token_)).transferFrom(token_,from_, to_, amount_);
            else
                IERC20(token_).transferFrom(from_, to_, amount_);
        }
        else if (t == Token.TypeERC721) 
        {
            if (tokenplace_.machine(token_)!=address(0))
                IMERC721(tokenplace_.machine(token_)).safeTransferFrom(token_,from_, to_, id_, data_);
            else
                IERC721(token_).safeTransferFrom(from_, to_, id_, data_);
        }
        else if (t == Token.TypeERC1155) 
        {
            //if (tokenplace_.machine(token_)!=address(0))
            //    IMERC155(tokenplace_.machine(token_)).safeTransferFrom(token_,from_, to_, id_, amount_, data_);
            //else
                IERC1155(token_).safeTransferFrom(from_, to_, id_, amount_, data_);
        }
        else revert("transferFrom: Unsupported token type");
    }*/
    function transferFrom(
        TokenPlace tokenplace_,
        address from_,
        address to_,
        address token_,
        uint256[] memory ids_,
        uint256[] memory amounts_,
        bytes memory data_
    ) internal {
        uint40 features_ = tokenplace_.features(token_);

        require(
            Token.transferable(token_, features_, 0),
            "TokenPlaceLib: transferFrom Token must be transferable"
        );
        uint40 t = Token.typeOf(features_);
        if (t == Token.TypeCoin) 
        {
            if (from_==address(this))
                for (uint i = 0 ;i< amounts_.length;i++)
                    payable(to_).transfer(amounts_[i]);
            else if (to_==address(this)) 
                    require(msg.sender==from_,"transferFrom: Invalid from for coin");
            else require(false, "transferFrom: Invalid operation for Coin");
        }
        else if ((t == Token.TypeERC20) || (t == Token.TypeERC777))
        {
            for (uint i = 0 ;i< amounts_.length;i++)
                if (tokenplace_.machine(token_)!=address(0))
                    IMERC777(tokenplace_.machine(token_)).transferFrom(token_,from_, to_, amounts_[i]);
                else
                    IERC20(token_).transferFrom(from_, to_, amounts_[i]);
        }
        else if (t == Token.TypeERC721) 
        {
            if (tokenplace_.machine(token_)!=address(0))
                for (uint i = 0 ;i< ids_.length;i++)
                    IMERC721(tokenplace_.machine(token_)).safeTransferFrom(token_,from_, to_, ids_[i], data_);
            else
                for (uint i = 0 ;i< ids_.length;i++)
                    IERC721(token_).safeTransferFrom(from_, to_, ids_[i], data_);
        }
        else if (t == Token.TypeERC1155) 
        {
            //if (tokenplace_.machine(token_)!=address(0))
            //    IMERC155(tokenplace_.machine(token_)).safeBatchTransferFrom(token_,from_, to_, ids_, amounts_, data_);
            //else
                IERC1155(token_).safeBatchTransferFrom(from_, to_, ids_, amounts_, data_);
        }
        else revert("transferFrom: Unsupported token type");
    }    

    function balanceOf(
        TokenPlace tokenplace_,
        address from_,
        address token_,
        uint256 id_
    ) internal view returns (uint256) {
        uint40 features_ = tokenplace_.roFeatures(token_);
        require(
            Token.transferable(token_, features_, id_),
            "TokenPlaceLib: transferFrom Token must be transferable"
        );
        uint40 t = Token.typeOf(features_);
        if (t == Token.TypeCoin) {
            return from_.balance;
        }
        else if ((t == Token.TypeERC20) || (t == Token.TypeERC777))
        {
            if (tokenplace_.machine(token_)!=address(0))
                return IMERC777(tokenplace_.machine(token_)).balanceOf(token_,from_);
            else
                return IERC20(token_).balanceOf(from_);
        }
        else if (t == Token.TypeERC721) 
        {
            if (tokenplace_.machine(token_)!=address(0))
                return IMERC721(tokenplace_.machine(token_)).ownerOf(token_,id_)==from_ ? 1:0;
            else
                return IERC721(token_).ownerOf(id_)==from_ ? 1:0;
        }
        else if (t == Token.TypeERC1155) 
        {
            //if (tokenplace_.machine(token_)!=address(0))
            //    IMERC155(tokenplace_.machine(token_)).safeTransferFrom(token_,from_, to_, id_, amount_, data_);
            //else
                return IERC1155(token_).balanceOf(from_, id_);
        }
        else revert("transferFrom: Unsupported token type");
    }
    
}

// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../../interfaces/IAble.sol";
import "../../interfaces/IContractWithId.sol";

library Token {
    address constant COIN = address(0); //0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE

    uint40 constant TypeMask =              0x00000000ff; //
    uint40 constant TypeCoin =              0x0000000001; // is Coin
    uint40 constant TypeGeneric =           0x0000000002; // is Generic TokenLib | Supports ITokenType
    uint40 constant TypeERC20 =             0x0000000004; // is ERC20
    uint40 constant TypeERC721 =            0x0000000008; // is ERC721
    uint40 constant TypeERC777 =            0x0000000010; // is ERC777
    uint40 constant TypeERC1155 =           0x0000000020; // is ERC1155
    uint40 constant TypeReferral =          0x00000000ff; // is a Referral TokenLib

    uint40 constant TT =                    0x0000000700; // Mask FT/NFT/MT
    uint40 constant FT =                    0x0000000100; // is FT
    uint40 constant NFT =                   0x0000000200; // is NFT
    uint40 constant MT =                    0x0000000400; // is Multi Token
    uint40 constant TID =                   0x0000000800; // has TokenId
    uint40 constant ERC165 =                0x0000001000; // Supports IERC165
    uint40 constant Machined =              0x0000002000; // Supports IMachined
    uint40 constant ContractWithId =        0x0000004000; // Contract IContractWithId
    uint40 constant Contains =              0x0000008000; // Supports IContains
    uint40 constant Equiv =                 0x0000010000; // Supports IEquiv
    uint40 constant Certified =             0x0000020000; // Supports ICertified

    uint40 constant SupportTransferable =   0x0001000000; // Supports ITransferable
    uint40 constant SupportBankable =       0x0002000000; // Supports IBankable
    uint40 constant SupportTradable =       0x0004000000; // Supports ITradeable
    uint40 constant SupportGateable =       0x0008000000; // Supports IGateable
    uint40 constant SupportContainable =    0x0010000000; // Supports IContainable

    uint40 constant nottransferable =       0x0100000000; // Isn't transferable
    uint40 constant notbankable =           0x0200000000; // Isn't bankable
    uint40 constant notgateable =           0x0400000000; // Isn't gateable
    uint40 constant notcontainable =        0x0800000000; // Isn't containable

    //uint40 constant onlyWithCoin =          0x0100000000; // Is tradeable only With Coin

    //uint64 constant notequivable =          0x0000040000000000; // Isn't equivable
    //uint64 constant notfungible =           0x0000080000000000; // Isn't fungible

    //uint64 constant SupportTokenCertified = 0x0000010000000000; // Supports ITokenEquivalent
    //uint64 constant SupportTokenEquivalent = 0x0000020000000000; // Supports ITokenEquivalent

    function features(address token_) internal view returns (uint40 features_) {
        return features(token_, false);
    }

    function features(address token_, bool canfail_)
        internal
        view
        returns (uint40 features_)
    {
        while (true) {
            if (token_ == COIN) {
                features_ = TypeCoin | FT;
                break;
            }
            if (token_.code.length == 0) {
                require(!canfail_, "Token: Unresolved token type");
                break;
            }
            try IERC165(token_).supportsInterface(type(IERC165).interfaceId) {
                features_ |= ERC165;
            } catch {}

            if (features_ & ERC165 != 0) {
                if (IERC165(token_).supportsInterface(type(IERC777).interfaceId)) 
                    features_ |= TypeERC777 | FT;
                else if (IERC165(token_).supportsInterface(type(IERC20).interfaceId)) 
                    features_ |= TypeERC20 | FT;
                else if (IERC165(token_).supportsInterface(type(IERC721).interfaceId)) 
                    features_ |= TypeERC721 | NFT | ContractWithId | TID;
                else if (IERC165(token_).supportsInterface(type(IERC1155).interfaceId)) 
                    features_ |= TypeERC1155 | MT | TID;                   
                if (IERC165(token_).supportsInterface(type(IContractWithId).interfaceId)) 
                    features_ |= ContractWithId;
                if (IERC165(token_).supportsInterface(type(IContains).interfaceId)) 
                    features_ |= Contains;
                if (IERC165(token_).supportsInterface(type(IEquiv).interfaceId)) 
                    features_ |= Equiv;
                if (IERC165(token_).supportsInterface(type(IMachined).interfaceId)) 
                    features_ |= Machined;
                if (IERC165(token_).supportsInterface(type(IContainable).interfaceId)) 
                    features_ |= SupportContainable;
                if (IERC165(token_).supportsInterface(type(ITransferable).interfaceId)) 
                    features_ |= SupportTransferable;
            }
            if (features_ & TypeMask == 0) {
                try IERC777(token_).granularity() {features_ = TypeERC777 | FT;} catch {}
                try IERC20(token_).totalSupply() {features_ = TypeERC20 | FT;} catch {}
            }
            break;
        }
        require(features_ & TypeMask != 0 || !canfail_,"Token: Unresolved token type");
    }

    function typeOf(uint40 features_) internal view returns (uint40) {
        return features_ & TypeMask;
    }

    function transferable( address token_, uint40 features_, uint256 tokenId_ ) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        if (features_ & SupportTransferable == 0) return true;
        if (features_ & nottransferable != 0) return false;
        return ITransferable(token_).transferable(tokenId_);
    }
/*
    function tradable( address token_, uint40 features_, uint256 tokenId_ ) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        if (features_ & SupportTradable == 0) return true;
        if (features_ & nottradable != 0) return false;
        return ITradable(token_).tradable(tokenId_);
    }
*/
    function gateable( address token_, uint40 features_, uint256 tokenId_ ) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        if (features_ & SupportGateable == 0) return true;
        if (features_ & notgateable != 0) return false;
        return IGateable(token_).gateable(tokenId_);
    }

    function containable( address token_, uint40 features_, uint256 tokenId_ ) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        if (features_ & SupportContainable == 0) return true;
        if (features_ & notcontainable != 0) return false;
        else return IContainable(token_).containable(tokenId_);
    }

    function contractWithId(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return features_ & ContractWithId != 0;
    }

    function erc165(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return features_ & ERC165 != 0;
    }

    function contains(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return features_ & Contains != 0;
    }
    function equiv(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return features_ & Equiv != 0;
    }
    function machined(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return features_ & Machined != 0;
    }
    function tid(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return features_ & (TypeERC721|TypeERC1155|TID) != 0;
    }
    function tt(uint40 features_) internal view returns (uint40) {
        return features_ & TT;
    }
    function mt(uint40 features_) internal view returns (bool) {
        return features_ & (TypeERC1155|MT) != 0;
    }
    function mt(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return mt(features_);
    }

    function nft(uint40 features_) internal view returns (bool) {
        return features_ & (TypeERC721|NFT) != 0;
    }
    function nft(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return nft(features_);
    }
    function ft(uint40 features_) internal view returns (bool) {
        return features_ & (TypeERC20|TypeERC777|FT) != 0;
    }
    function ft(address token_, uint40 features_) internal view returns (bool) {
        if (features_ == 0)
            features_ = features(token_, true);
        return ft(features_);
    }
/*
    function transferFrom(
        uint40 features_,
        address from_,
        address token_,
        uint256 v_,
        bytes memory data_
    ) internal {
        if (features_ == 0)
            features_ = features(token_, true);
        require(
            transferable(token_, features_, v_),
            "Token: transferFrom Token must be transferable"
        );
        uint40 t = typeOf(features_);
        if (t == TypeCoin) 
            {}
        else if (t == TypeERC20 || t == TypeERC777)
            IERC20(token_).transferFrom(from_, address(this), v_);
        else if (t == TypeERC721) 
            IERC721(token_).safeTransferFrom(from_, address(this), v_, data_);
        else require(false, "Token: Unknown type");
    }
    

    function transferTo(
        uint40 features_,
        address to_,
        address token_,
        uint256 v_,
        bytes memory data_
    ) internal {
        if (features_ == 0)
            features_ = features(token_, true);
        require(
            transferable(token_, features_, v_),
            "Token: transferFrom Token must be transferable"
        );

        uint40 t = typeOf(features_);
        if (t == TypeCoin) 
        {
            //(bool success, ) = to_.call{value: v_}(new bytes(0));
            //require(success,"failed transferFrom COIN");
            payable(to_).transfer(v_);
        }
        else if (t == TypeERC20 || t == TypeERC777)
            IERC20(token_).transferFrom(address(this),to_, v_);
        else if (t == TypeERC721) 
            IERC721(token_).safeTransferFrom(address(this), to_, v_, data_); 
        else require(false, "Token: Unknown type");
    }
*/
}

// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "./aMERC721.sol";


contract aMERC721Mint is aMERC721 {

    function safeMint(
        address token,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual {
        if (TokenPlace(location(kTokenPlace)).creatorOf(token) != _msgSender())
            revert Unauthorized(Unauthorized_Reason.onlyCreator);
        _safeMint(token, to, tokenId, _data);
    }

    function burn(
        address token,
        address from,
        uint256 tokenId
    ) public virtual {
        if (from!=ownerOf(token,tokenId)||(TokenPlace(location(kTokenPlace)).creatorOf(token) != _msgSender() && ownerOf(token,tokenId) != _msgSender()))
            revert Unauthorized(Unauthorized_Reason.onlyOwner);

        _burn(token, tokenId);
    }

}

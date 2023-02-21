// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "../machine/IMachine.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

interface IMERC721 is IMachine {

    //IMachine  function exists(address token_) external view  returns (bool);
    //ITokenMachine function features(address token_) external view returns (uint40);
    //IMachine  function creatorOf(address token_) external view  returns (address);

    function ownerOf(address token_, uint256 tokenId_) external view returns (address);
    function exists(address token_, uint256 tokenId_) external view returns (bool);
    //function tokenURI(address token_, uint256 tokenId_) external view returns (string memory);

    //function list(address token) external view returns (uint256[] memory);
    //function listOf(address token, address owner) external view returns (uint256[] memory);
    function balanceOf(address token, address owner) external view returns (uint256 balance);
    function safeTransferFrom( address token, address from, address to, uint256 tokenId, bytes calldata data ) external;
    function safeTransferFrom( address token, address from, address to, uint256 tokenId ) external;
    function transferFrom( address token, address from, address to, uint256 tokenId ) external;
    function approve( address token, address to, uint256 tokenId ) external;
    function getApproved(address token, uint256 tokenId) external view returns (address operator);
    function burn(address token, uint256 tokenId) external;
    function burn(uint256 tokenId) external;

}

// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IERC721Extended is IERC721 {
    function listOf(address owner) external view returns (uint256[] memory);
    function list() external view returns (uint256[] memory);
    function exists(uint256 tokenId_) external view returns (bool);
}

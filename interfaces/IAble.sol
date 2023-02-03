// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IContainable is IERC165 {
    function containable(uint256 tokenId_) external view returns (bool);
}
interface ITransferable is IERC165 {
    function transferable(uint256 tokenId_) external view returns (bool);
}
interface IContains {
    function content(uint256 tokenId_) external view returns (address[] memory token_,uint256[] memory id_,uint256[] memory v_);
    function content(uint256 tokenId_,address[] calldata token_) external view returns (uint256[][] memory id_,uint256[][] memory v_);
    function content(uint256 tokenId_,address token_) external view returns (uint256[] memory id_,uint256[] memory v_);
}

interface IGateable is IERC165 {
    function gateable(uint256 tokenId_) external view returns (bool);
}

interface IEquiv is IERC165 {
    function equiv() external view returns (uint56 chainId_,address token_, uint40 features);
}

interface IMachined is IERC165 {
    function machine() external view returns (address);
}
/*
interface ITradable is IERC165 {
    function tradable(uint256 tokenId_) external view returns (bool);
//    function onlyWithCoin(uint256 tokenId_) external view returns (bool);
}

interface IBankable is IERC165 {
    function bankable(uint256 tokenId_) external view returns (bool);
}



interface IEquivable is IERC165 {
    function equivable(uint256 tokenId_) external view returns (bool);
}
interface ISealable is IERC165 {
    function sealable(uint256 tokenId_) external view returns (bool);
}
*/
/*
interface IFungible is IERC165 {
    function fungible(uint256 tokenId_) external view returns (bool);
}
interface IGranularity is IERC165 {
    function granularity(uint256 tokenId_) external view returns (uint256);
}
interface ITokenType is IERC165 {
    function tokentype(uint256 tokenId_) external view returns (bytes4);
}
*/
/*
interface IEquiv {
    function getEquiv(uint256 tokenId_) external view returns (STokenV memory tokens_);
}
*/
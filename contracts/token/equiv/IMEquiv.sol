// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;


interface IMEquiv {
    function equiv(address token_) external view returns (uint56 chainId_,address tokenout_, uint40 features);
    function get(address creator_,uint56 remotechainId_,address remotetoken_) external view returns (address);
    function get(uint56 remotechainId_,address remotetoken_) external view returns (address);

    function declare(uint56 remotechainId_,address remotetoken_,uint40 remotefeatures_, string memory remotesymbol_, string memory remotename_) external returns (address);
    function create(uint56 remotechainId_,address remotetoken_,uint40 remotefeatures_, string memory remotesymbol_, string memory remotename_) external returns (address);
    function deploy(address token_) external;
    
}

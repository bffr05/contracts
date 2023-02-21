// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

interface ITokenMachine {
    function features(address token_) external view returns (uint40);
}

interface ITokenPlace {
    event Tokened(address indexed token);

    
    function features(address token_) external returns (uint40);
    function roFeatures(address token_) external view returns (uint40);
    function machine(address token_) external view returns (address);
    function exists(address token_) external view returns (bool);
    function name(address token_) external view returns (string memory);
    function symbol(address token_) external view returns (string memory);
    function creatorOf(address token_) external view returns (address);

    function declare( address token_, address machine_, address creator_, string memory symbol_, string memory name_) external ; 
}

interface IRTokenPlace {
    function update( address token_, string memory symbol_, string memory name_) external;
    function updateCoin( string memory symbol_, string memory name_) external;
}

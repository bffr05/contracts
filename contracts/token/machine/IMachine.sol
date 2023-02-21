// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "../tokenplace/TokenPlace.sol";


interface IMachine is ITokenMachine
{
    event TokenTransfer( address indexed token, address indexed from, address indexed to, uint256 v );
    event TokenApproval( address indexed token, address indexed owner, address indexed approved, uint256 v );
    event TokenMinted( address indexed token, address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData    ); 
    event TokenBurned(address indexed token,address indexed operator,address indexed from,uint256 amount,bytes data,bytes operatorData ); 
    event TokenSent(address indexed token,address operator,address indexed from,address indexed to,uint256 amount,bytes data,bytes operatorData );

    function exists(address token_) external view  returns (bool);
    //ITokenMachine function features(address token_) external view returns (uint40);
    function name(address token_) external view  returns (string memory);
    function symbol(address token_) external view  returns (string memory);
    function creatorOf(address token_) external view  returns (address);

    //function deploy(address token_) external;
}

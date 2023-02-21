// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "../machine/IMachine.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

interface IMERC777 is IMachine {

    //IMachine  function exists(address token_) external view  returns (bool);
    //ITokenMachine function features(address token_) external view returns (uint40);
    //IMachine  function creatorOf(address token_) external view  returns (address);

    function getOwner(address token) external view returns (address);
    //IMachine  function name(address token) external view returns (string memory);
    //IMachine  function symbol(address token) external view returns (string memory);
    function decimals(address token) external view returns (uint8);
    function granularity(address token) external view returns (uint256);
    function totalSupply(address token) external view returns (uint256);
    function balanceOf(address token, address owner) external view returns (uint256);

    function transfer(address token,address recipient,uint256 amount ) external returns (bool);
    function allowance(address token,address holder,address spender ) external view returns (uint256);
    function approve(address token,address spender,uint256 value ) external returns (bool);
    function transferFrom(address token,address holder,address recipient,uint256 amount ) external returns (bool);
    function send(address token,address recipient,uint256 amount,bytes calldata data ) external;
    function burn(address token,uint256 amount,bytes calldata data ) external;
    function isOperatorFor(address operator, address tokenHolder)external view returns (bool);
    function operatorSend(address token,address sender,address recipient,uint256 amount,bytes calldata data,bytes calldata operatorData ) external;
    function operatorBurn(address token,address account,uint256 amount,bytes calldata data,bytes calldata operatorData ) external;
    function mint(address token,address to,uint256 amount,bytes memory userData,bytes memory operatorData ) external ; //onlyCreator
    function burn(address token,address from,uint256 amount,bytes memory userData,bytes memory operatorData ) external ; //onlyCreator

    function authorizeOperator(address operator) external;
    function revokeOperator(address operator) external;
    function defaultOperators() external view returns (address[] memory);

    function mint(address to,uint256 amount,bytes memory userData,bytes memory operatorData ) external ; //onlyForwarder | onlyCreator
    function burn(address from,uint256 amount,bytes memory userData,bytes memory operatorData ) external ; //onlyForwarder | onlyCreator
    
}


// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;

import "../machine/IMachine.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IMERC1155 is IMachine {



    event TokenTransferSingle(address indexed token,address operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TokenTransferBatch(
        address indexed token,
        address operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    //IMachine  function exists(address token_) external view  returns (bool);
    //ITokenMachine function features(address token_) external view returns (uint40);
    //IMachine  function creatorOf(address token_) external view  returns (address);

    //IMachine  function name(address token) external view returns (string memory);
    //IMachine  function symbol(address token) external view returns (string memory);

    function balanceOf(address token,address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address token,address[] calldata accounts, uint256[] calldata ids)  external view returns (uint256[] memory);
    //function balanceOfBatch(address[] calldata tokens,address[] calldata accounts, uint256[] calldata ids)  external view returns (uint256[] memory);

    function safeTransferFrom(address token,address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
    //function safeTransferFrom(address from,address to,uint256 id,uint256 amount,bytes calldata data) external;
    function safeBatchTransferFrom(address token,address from,address to,uint256[] calldata ids,uint256[] calldata amounts, bytes calldata data) external;
    //function safeBatchTransferFrom(address from,address to,uint256[] calldata ids,uint256[] calldata amounts, bytes calldata data) external;

    //function totalSupply(address token,uint256 id) external view returns (uint256);
    //function exists(address token,uint256 id) external view  returns (bool);
    //function uri(address token,uint256 id) external view returns (string memory);
    //function list(address token) external view returns (uint256[] memory);
    //function listOf(address token, address owner) external view returns (uint256[] memory);

    //function mint(address to,uint256 amount,bytes memory userData,bytes memory operatorData ) external ; //onlyForwarder | onlyCreator
    
}


// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.17;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";


interface IContractWithId is IERC165 {

    function ownerOf(uint256 id_) external view returns (address);
    function exists(uint256 id_) external view returns (bool);
    
    function transfer(address to_, uint256 id_) external;
    function transferFrom(address from_, address to_, uint256 id_) external;
}
// SPDX-License-Identifier: MIT
// Beef Contracts v0.0.0 hello@mcdu.com

pragma solidity ^0.8.4;

import "./ForwarderContext.sol";


abstract contract MiniWallet is ForwarderContext {

    mapping(address => uint256) internal _wallets;

    receive() external virtual payable {
        _wallets[_msgSender()]+=msg.value;
    }
    function refund() external {
        uint256 value = _wallets[_msgSender()];
        _wallets[_msgSender()] = 0;
        payable(_msgSender()).transfer(value);
    }

    modifier stack() virtual {
        _wallets[_msgSender()]+=msg.value;
        _;
    }

}